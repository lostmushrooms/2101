DROP TYPE IF EXISTS gender_type CASCADE;
DROP TYPE IF EXISTS species_type CASCADE;
DROP TYPE IF EXISTS weight_type CASCADE;
DROP TYPE IF EXISTS service_type CASCADE;

DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Owners CASCADE;
DROP TABLE IF EXISTS Caretakers CASCADE;
DROP TABLE IF EXISTS PetSpecies CASCADE;
DROP TABLE IF EXISTS WeightClasses CASCADE;
DROP TABLE IF EXISTS Pets CASCADE;
DROP TABLE IF EXISTS Chats CASCADE;
DROP TABLE IF EXISTS Availabilities CASCADE;
DROP TABLE IF EXISTS ServiceTypes CASCADE;
DROP TABLE IF EXISTS OfferedCares CASCADE;
DROP TABLE IF EXISTS Bids CASCADE;
DROP TABLE IF EXISTS AcceptedBids CASCADE;

--create some types
CREATE TYPE gender_type AS ENUM (
	'male',
	'female',
	'others',
	'unknown'
);

CREATE TYPE species_type AS ENUM (
	'dog',
	'cat',
	'others',
	'unknown'
);

CREATE TYPE weight_type AS ENUM (
	'small', --<10kg
	'medium', --10kg-25.9kg
	'large', --26kg-44kg
	'giant', -->44kg
	'unknown'
);

CREATE TYPE service_type AS ENUM (
	'hotel', --pet stays at caretaker's location
	'petsitting', --pet and caretaker stays at owner's location
	'drop-in visits', --checking in at owner's location every now and then
	'daycare' --daytime care at caretaker's location for when owners are at work (charges less than 'hotel')
);

--create tables
CREATE TABLE Users (
	username VARCHAR(50), --increase if necessary
	email VARCHAR(100) UNIQUE NOT NULL , --increase if necessary
	password VARCHAR(64) NOT NULL,
	phone_number VARCHAR(20),
	PRIMARY KEY (username)
);

CREATE TABLE Owners (
	username VARCHAR(50),
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES Users (username) ON DELETE CASCADE
);

CREATE TABLE Caretakers (
	username VARCHAR(50),
	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES Users (username) ON DELETE CASCADE
);

CREATE TABLE Pets (
	pid INTEGER, --weak unique id of pet
	oname VARCHAR(50), --username of owner
	pname VARCHAR(50), --non-unique name of pet
	gender gender_type NOT NULL DEFAULT 'unknown',
	species species_type NOT NULL DEFAULT 'unknown',
	weight_class weight_type NOT NULL DEFAULT 'unknown',
	biography VARCHAR(500), --bio of the pet
	PRIMARY KEY (pid, oname),
	FOREIGN KEY (oname) REFERENCES Owners (username) ON DELETE CASCADE
);
	
CREATE TABLE Chats (
	oname VARCHAR(50),
	ctname VARCHAR(50),
	from_owner BOOL, --True if message was sent by owner, else message was sent by caretaker.
	time TIMESTAMP,
	message TEXT,
	PRIMARY KEY (oname, ctname, from_owner, time),
	FOREIGN KEY (oname) REFERENCES Owners (username) ON DELETE CASCADE,
	FOREIGN KEY (ctname) REFERENCES Caretakers (username) ON DELETE CASCADE
);
		
CREATE TABLE Availabilities (
	ctname VARCHAR(50), --username of caretaker who advertised this availability
	start_ts TIMESTAMP,
	end_ts TIMESTAMP,
	PRIMARY KEY (ctname, start_ts, end_ts),
	FOREIGN KEY (ctname) REFERENCES Caretakers(username) ON DELETE CASCADE
);

/**
Services offered by care taker
**/
CREATE TABLE OfferedCares (
    ctname VARCHAR(50),
	species species_type NOT NULL,
	weight_class weight_type NOT NULL,
	service service_type NOT NULL,
	extra_descriptions VARCHAR(500),
	FOREIGN KEY (ctname) REFERENCES Caretakers(username) ON DELETE CASCADE,
	PRIMARY KEY (ctname, species, weight_class, service)
);


CREATE TABLE Bids (
	id SERIAL PRIMARY KEY,
	oname VARCHAR(50),
	ctname VARCHAR(50),
	ctstart_ts TIMESTAMP, 
	ctend_ts TIMESTAMP, 
	ostart_ts TIMESTAMP, --check that this start date is after the Availability's start timestamp
	oend_ts TIMESTAMP, --check that this end date if before the Availability's end timestamp
	bidded_price_per_hour NUMERIC(10,2),
	FOREIGN KEY (oname) REFERENCES Owners(username) ON DELETE CASCADE,
	FOREIGN KEY (ctname, ctstart_ts, ctend_ts) REFERENCES Availabilities(ctname, start_ts, end_ts) ON DELETE CASCADE
);

CREATE TABLE AcceptedBids (
	id INTEGER, --id of bid
	orating INTEGER, --rating that the caretaker gave the owner from 1 to 5
	ctrating INTEGER, --rating that the owner gave the caretaker from 1 to 5
	ocomments VARCHAR(2000), --comments that the caretaker gave the owner
	ctcomments VARCHAR(2000), --comments that the owner gave the caretaker
	FOREIGN KEY (id) REFERENCES Bids(id) ON DELETE CASCADE,
	PRIMARY KEY (id)
);


--Triggers
--Caretaker cannot be Owner.
CREATE OR REPLACE FUNCTION not_owner()
RETURNS TRIGGER AS
$$
BEGIN 
	IF EXISTS (
		SELECT 1
		FROM Owners
		WHERE Owners.username = NEW.username
	) THEN RETURN NULL;
	ELSE RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER not_owner_trig
BEFORE INSERT OR UPDATE
ON Caretakers
FOR EACH ROW
EXECUTE PROCEDURE not_owner();

--Owner cannot be Caretaker.
CREATE OR REPLACE FUNCTION not_caretaker()
RETURNS TRIGGER AS
$$
BEGIN 
	IF EXISTS (
		SELECT 1
		FROM Caretakers
		WHERE Caretakers.username = NEW.username
	) THEN RETURN NULL;
	ELSE RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER not_caretaker_trig
BEFORE INSERT OR UPDATE
ON Owners
FOR EACH ROW
EXECUTE PROCEDURE not_caretaker();

-- --A care taker should not have any availabilities, u and v where u.start_ts <= v.end_ts but u.end_ts >= v.start_ts. This is an overlap and we will merge these results to create
-- --another availability which includes both timeframes. We will do this by deleting all previous entries which are in this overlap, and finally adding one entry which goes from
-- --the minimum of all the start_ts until the maximum of all the end_ts.
-- CREATE OR REPLACE FUNCTION merge_availability()
-- RETURNS TRIGGER AS
-- $$
-- DECLARE tscursor CURSOR (new_start_ts TIMESTAMP, new_end_ts TIMESTAMP) FOR
-- 	SELECT *
-- 	FROM Availabilities A
-- 	WHERE A.start_ts <= new_end_ts AND A.end_ts >= new_start_ts;
-- 	min_start_ts TIMESTAMP;
-- 	max_end_ts TIMESTAMP;
-- 	availability RECORD;
-- BEGIN
-- 	OPEN tscursor(new_start_ts := new.start_ts,	 new_end_ts := new.end_ts);
-- 	min_start_ts := new.start_ts;
-- 	max_end_ts := new.end_ts;
-- 	--at every iteration we want to keep track of the current minimum start_ts and maximum end_ts, as well as deleting the entry which had been in the overlap.
-- 	LOOP
-- 		FETCH tscursor INTO availability;
-- 		EXIT WHEN NOT FOUND;
-- 		min_start_ts := LEAST(availability.start_ts, min_start_ts);
-- 		max_end_ts := GREATEST(availability.end_ts, max_end_ts);
-- 		DELETE FROM Availabilities A
-- 		where A.ctname = availability.ctname AND A.start_ts = availability.start_ts AND A.end_ts = availability.end_ts;
-- 	END LOOP;
-- 	CLOSE tscursor;
-- 	--finally insert 1 entry into Availability which encompasses all the deleted entries as well as the newest entry.
-- 	INSERT INTO Availabilities VALUES (new.ctname, min_start_ts, max_end_ts);
-- 	RETURN NULL;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER merge_trig
-- AFTER INSERT OR UPDATE ON Availabilities
-- FOR EACH ROW
-- EXECUTE PROCEDURE merge_availability();

------------------
--| Dummy Data |--
------------------

-- Users

INSERT INTO Users (username, email, password, phone_number)
VALUES 
	('Miaaaaa97', '381453218@qq.com', '$2b$10$ONZuakkV8QXIG4ZIjua3ZODsEsNWjNLgtxGtKP4sL3wVZqdgLRH2S', 88888888),
	('Miaaaaa666', 'zhangtieze26@gmail.com', '$2b$10$2ll0FMZUTBxwJsUxsikYhOQdRox/Iro5QvVAAawHuW/XUDsqG.9nq', 88888888),
	('Alice00', 'alice00@hotmail.com', '$2b$10$uzE/Z3QSnaHJOJMyGL4OXOM9LjtF38KYhAX/RA6DAeZSyXqUMc9C2', 11111111),
	('Bob00', 'bob00@hotmail.com', '$2b$10$jr9buQPUiCdj4yuIKsvCR.6/aZBEDsQTlU0C7cutrIkYXuOBzj4xq', 11111112);

-- Owners

INSERT INTO Owners (username)
VALUES 
	('Miaaaaa97'),
	('Alice00');

-- Caretakers
INSERT INTO Caretakers (username)
VALUES 
	('Miaaaaa666'),
	('Bob00');

-- Pets
INSERT INTO Pets(pid, oname, pname, biography) 
VALUES 
    (1, 'Alice00', 'Prince', 'cute cute'),
	(2, 'Alice00', 'Princess', 'paw paw'),
	(1, 'Miaaaaa97', 'Orange', 'ooooooorange'),
	(2, 'Miaaaaa97', 'Purp', 'purrrrrrrrrp');

-- Availabilities
INSERT INTO Availabilities (ctname, start_ts, end_ts) 
VALUES
    ('Bob00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD')),
	('Bob00', to_date('2019-06-02', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD')),
	('Miaaaaa666', to_date('2019-04-19', 'YYYY-MM-DD'), to_date('2019-05-06', 'YYYY-MM-DD')),
	('Miaaaaa666', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD')),
	('Miaaaaa666', to_date('2019-07-20', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'));

-- Bids
INSERT INTO Bids (id, oname, ctname, ctstart_ts, ctend_ts, ostart_ts, oend_ts, bidded_price_per_hour)
VALUES
	(1, 'Miaaaaa97', 'Miaaaaa666', to_date('2019-04-19', 'YYYY-MM-DD'), to_date('2019-05-06', 'YYYY-MM-DD'), to_date('2019-04-20', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 20),
	(2, 'Alice00', 'Miaaaaa666', to_date('2019-04-19', 'YYYY-MM-DD'), to_date('2019-05-06', 'YYYY-MM-DD'), to_date('2019-04-20', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 25),
	(3, 'Miaaaaa97', 'Miaaaaa666', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), 20),
	(4, 'Alice00', 'Miaaaaa666', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), 25),
	(5, 'Miaaaaa97', 'Miaaaaa666', to_date('2019-07-20', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), to_date('2019-03-31', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), 20),
	(6, 'Alice00', 'Miaaaaa666', to_date('2019-07-20', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), to_date('2019-03-31', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), 25),
	(7, 'Miaaaaa97', 'Bob00', to_date('2019-06-02', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 20),
	(8, 'Alice00', 'Bob00', to_date('2019-06-02', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 25),
	(9, 'Miaaaaa97', 'Bob00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), 20),
	(10, 'Alice00', 'Bob00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), 25);

-- Accepted Bids
INSERT INTO AcceptedBids (id, orating, ctrating, ocomments, ctcomments)
VALUES
	(2, 5, 5, 'good service', 'cute cat'),
	(3, 5, 5, 'good service', 'cute dog'),
	(7, 5, 5, 'good service', 'cuuuuute cat'),
	(10, 5, 5, 'good service', 'cuuuuute dog');