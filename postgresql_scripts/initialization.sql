DROP TYPE IF EXISTS gender_type CASCADE;
DROP TYPE IF EXISTS species_type CASCADE;
DROP TYPE IF EXISTS weight_type CASCADE;
DROP TYPE IF EXISTS service_type CASCADE;

DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Owners CASCADE;
DROP TABLE IF EXISTS Caretakers CASCADE;
DROP TABLE IF EXISTS Pets CASCADE;
DROP TABLE IF EXISTS Chats CASCADE;
DROP TABLE IF EXISTS Availabilities CASCADE;
DROP TABLE IF EXISTS OfferedCares CASCADE;
DROP TABLE IF EXISTS Bids CASCADE;
DROP TABLE IF EXISTS AcceptedBids CASCADE;
DROP TABLE IF EXISTS Payments CASCADE;

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
	oname VARCHAR(50), --username of owner
	pname VARCHAR(50), --weak unique name of pet
	gender gender_type NOT NULL DEFAULT 'unknown',
	species species_type NOT NULL DEFAULT 'unknown',
	weight_class weight_type NOT NULL DEFAULT 'unknown',
	biography VARCHAR(500), --bio of the pet
	PRIMARY KEY (pname, oname),
	FOREIGN KEY (oname) REFERENCES Owners (username) ON DELETE CASCADE
);
	
CREATE TABLE Chats (
	oname VARCHAR(50),
	ctname VARCHAR(50),
	from_owner BOOL, --True if message was sent by owner, else message was sent by caretaker.
	time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	message TEXT,
	PRIMARY KEY (oname, ctname, from_owner, time),
	FOREIGN KEY (oname) REFERENCES Owners (username) ON DELETE CASCADE,
	FOREIGN KEY (ctname) REFERENCES Caretakers (username) ON DELETE CASCADE
);
		
CREATE TABLE Availabilities (
	id INTEGER PRIMARY KEY,
	ctname VARCHAR(50), --username of caretaker who advertised this availability
	start_date DATE,
	end_date DATE,
	is_opened BOOL NOT NULL DEFAULT True,
	FOREIGN KEY (ctname) REFERENCES Caretakers(username) ON DELETE CASCADE,
	CHECK (start_date <= end_date)
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
	id INTEGER PRIMARY KEY,
	availabilityId INTEGER NOT NULL,
	oname VARCHAR(50),
	ostart_date DATE, --check that this start date is after the Availability's start date
	oend_date DATE, --check that this end date if before the Availability's end date
	bidded_price_per_hour NUMERIC(10,2),
	extra_descriptions VARCHAR(500),
	FOREIGN KEY (availabilityId) REFERENCES Availabilities(id) ON DELETE CASCADE,
	FOREIGN KEY (oname) REFERENCES Owners(username) ON DELETE CASCADE,
	CHECK (ostart_date <= oend_date),
	CHECK (bidded_price_per_hour >= 0)
);

CREATE TABLE AcceptedBids (
	id INTEGER, --id of bid
	orating INTEGER, --rating that the caretaker gave the owner from 1 to 5
	ctrating INTEGER, --rating that the owner gave the caretaker from 1 to 5
	ocomments VARCHAR(2000), --comments that the caretaker gave the owner
	ctcomments VARCHAR(2000), --comments that the owner gave the caretaker
	FOREIGN KEY (id) REFERENCES Bids(id) ON DELETE CASCADE,
	PRIMARY KEY (id),
	CHECK (1<=orating AND orating <=5),
	CHECK (1<=ctrating AND ctrating <= 5)
);

--weak entity to acceptedBid
CREATE TABLE Payments (
	payment_id INTEGER NOT NULL,
	id INTEGER, --id of accepted bid
	value DECIMAL(12,2), --value of payment (positive if from Owner to Caretaker)
	FOREIGN KEY (id) REFERENCES Bids(id) ON DELETE CASCADE,
	PRIMARY KEY (payment_id, id)
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

--For Availabilities table, for any particular user, we need to prevent overlapping open availabilities. 
CREATE OR REPLACE FUNCTION valid_availability()
RETURNS TRIGGER AS
$$
BEGIN 
	IF EXISTS (
		SELECT 1
		FROM Availabilities A
		WHERE A.ctname = NEW.ctname AND A.start_date <= NEW.end_date AND A.end_date >= NEW.start_date AND A.is_opened = True
	) THEN RETURN NULL;
	ELSE RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

--For Bid table, we need ostart_date >= referenced availability's start_date and oend_date <= referenced availability's end_date, and the referenced availability needs to be open.
CREATE OR REPLACE FUNCTION valid_bid()
RETURNS TRIGGER AS
$$
DECLARE datecursor CURSOR (new_start_date DATE, new_end_date DATE) FOR
	SELECT *
	FROM Availabilities A
 	WHERE A.start_date <= new_end_date AND A.end_date >= new_start_date AND A.ctname = new.ctname;
	final_start_date DATE;
	final_end_date DATE;
	availability RECORD;
BEGIN
	OPEN datecursor(new_start_date := new.start_date, new_end_date := new.end_date);
	final_start_date := new.start_date;
	final_end_date := new.end_date;
	--first loop to extract the final start_date and end_date.
	LOOP
		FETCH datecursor INTO availability;
		EXIT WHEN NOT FOUND;
		final_start_date := LEAST(availability.start_date, final_start_date);
		final_end_date := GREATEST(availability.end_date, final_end_date);
		raise notice 'a';
	END LOOP;
	MOVE BACKWARD ALL FROM datecursor;
	ALTER TABLE Bids DISABLE TRIGGER ALL; --temporarily disable constraindate for Bids so that id can be altered.
	--second loop to update Bids (which has a foreign reference to Availabilities) and delete entries in Availabilities which are in the overlap.
	LOOP
		FETCH datecursor INTO availability;
		EXIT WHEN NOT FOUND;
		UPDATE Bids B
		SET availabilityId = new.id
		where B.availabilityId = availability.id;
		DELETE FROM Availabilities A WHERE CURRENT OF datecursor;
		raise notice 'b';
	END LOOP;
	CLOSE datecursor;
	ALTER TABLE Bids ENABLE TRIGGER ALL; 
	--finally insert 1 entry into Availability which encompasses all the deleted entries as well as the newest entry.
	RETURN (new.id, new.ctname, final_start_date, final_end_date);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER valid_bid_trig
BEFORE INSERT OR UPDATE
ON Bids
FOR EACH ROW
EXECUTE PROCEDURE valid_bid();


--Due to covering constraint of the ISA relationship, insertion into Users is handled by js-side logic, whereas 
--deletion from Owners and Caretakers is handled using the following triggers.
CREATE OR REPLACE FUNCTION delete_ISA()
RETURNS TRIGGER AS
$$
BEGIN 
	DELETE FROM Users U
	where U.username = new.username;
	RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_from_owners
AFTER DELETE
ON Owners
FOR EACH ROW
EXECUTE PROCEDURE delete_ISA();

CREATE TRIGGER delete_from_caretakers
AFTER DELETE
ON Caretakers
FOR EACH ROW
EXECUTE PROCEDURE delete_ISA();

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
INSERT INTO Pets(oname, pname, biography) 
VALUES 
    ('Alice00', 'Prince', 'cute cute'),
	('Alice00', 'Princess', 'paw paw'),
	('Miaaaaa97', 'Orange', 'ooooooorange'),
	('Miaaaaa97', 'Purp', 'purrrrrrrrrp');

-- Availabilities
INSERT INTO Availabilities (id, ctname, start_date, end_date) 
VALUES
    (1, 'Bob00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD')),
	(2, 'Bob00', to_date('2019-06-02', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD')),
	(3, 'Miaaaaa666', to_date('2019-04-19', 'YYYY-MM-DD'), to_date('2019-05-06', 'YYYY-MM-DD')),
	(4, 'Miaaaaa666', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD')),
	(5, 'Miaaaaa666', to_date('2019-07-20', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'));


-- Bids
INSERT INTO Bids (id, availabilityId, oname, ostart_date, oend_date, bidded_price_per_hour)
VALUES
	(1, 3, 'Miaaaaa97', to_date('2019-04-20', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 20),
	(2, 3, 'Alice00', to_date('2019-04-20', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 25),
	(3, 4, 'Miaaaaa97', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), 20),
	(4, 4, 'Alice00', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD'), 25),
	(5, 5, 'Miaaaaa97', to_date('2019-03-31', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), 20),
	(6, 5, 'Alice00', to_date('2019-03-31', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'), 25),
	(7, 2, 'Miaaaaa97', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 20),
	(8, 2, 'Alice00',to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-05', 'YYYY-MM-DD'), 25),
	(9, 1, 'Miaaaaa97', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), 20),
	(10, 1, 'Alice00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD'), 25);
		

INSERT INTO Availabilities (id, ctname, start_date, end_date) 
VALUES
	(6,'Miaaaaa666', to_date('2018-05-15', 'YYYY-MM-DD'), to_date('2019-08-21', 'YYYY-MM-DD')),
	(7,'Miaaaaa666', to_date('2019-09-06', 'YYYY-MM-DD'), to_date('2019-09-26', 'YYYY-MM-DD')),
	(8,'Miaaaaa666', to_date('2019-09-05', 'YYYY-MM-DD'), to_date('2019-09-15', 'YYYY-MM-DD')),
	(9, 'Miaaaaa666',to_date('2020-09-11', 'YYYY-MM-DD'), to_date('2020-09-11', 'YYYY-MM-DD')) ;	


-- Accepted Bids
INSERT INTO AcceptedBids (id, orating, ctrating, ocomments, ctcomments)
VALUES
	(2, 1, 1, 'bad service', 'ugly cat'),
	(3, 5, 5, 'great service', 'cute dog'),
	(10, 4, 4, 'good service', 'cute cat');

-- Care Offered
INSERT INTO OfferedCares (ctname, species, weight_class, service, extra_descriptions)
VALUES
	('Miaaaaa666', 'cat', 'medium', 'daycare', '...'),
	('Miaaaaa666', 'dog', 'large', 'daycare', '...'),
	('Miaaaaa666', 'cat', 'medium', 'petsitting', '...'),
	('Bob00', 'dog', 'medium', 'daycare', '...'),
	('Bob00', 'cat', 'small', 'petsitting', '...');