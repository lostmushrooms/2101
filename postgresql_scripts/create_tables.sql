--drop tables first
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Owners CASCADE;
DROP TABLE IF EXISTS Caretakers CASCADE;
DROP TABLE IF EXISTS PetSpecies CASCADE;
DROP TABLE IF EXISTS WeightClasses CASCADE;
DROP TABLE IF EXISTS Pets CASCADE;
DROP TABLE IF EXISTS Chats CASCADE;
DROP TABLE IF EXISTS Availabilities CASCADE; --just a rename of 'Annoucement' in our discussed schema
DROP TABLE IF EXISTS ServiceTypes CASCADE;
DROP TABLE IF EXISTS OfferedCares CASCADE;
DROP TABLE IF EXISTS Bids CASCADE;
DROP TABLE IF EXISTS AcceptedBids CASCADE;
DROP TABLE IF EXISTS Payments CASCADE;
DROP TABLE IF EXISTS Reviews CASCADE;

--create tables
--Users table, add more attributes if necessary
CREATE TABLE Users (
	username VARCHAR(50), --increase if necessary
	email VARCHAR(100) UNIQUE NOT NULL , --increase if necessary
	password VARCHAR(20) NOT NULL,
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


CREATE TABLE PetSpecies (
	id INTEGER, --uniquely identifies a species. i.e. id = 1 refers to dog
	species VARCHAR(50) UNIQUE NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE WeightClasses (
	id INTEGER, --uniquely identifies a weight class. i.e. id = 1 refers to <2.5kg
	weight_class VARCHAR(50) UNIQUE NOT NULL, --'<2.5kg', '[2.5,5.0) kg', etc.
	PRIMARY KEY (id)
);	


CREATE TABLE Pets (
	pid INTEGER, --weak unique id of pet
	oname VARCHAR(50), --username of owner
	pname VARCHAR(50), --non-unique name of pet
	pet_sid INTEGER, --species of animal e.g. 1 refers to Dog
	--add breed as type string here maybe?
	weight_class_id INTEGER, --refers to weight class e.g. 1 refers to <2.5kg
	PRIMARY KEY (pid, oname),
	FOREIGN KEY (oname) REFERENCES Users (username) ON DELETE CASCADE,
	FOREIGN KEY (pet_sid) REFERENCES PetSpecies(id) ON UPDATE CASCADE,
	FOREIGN KEY (weight_class_id) REFERENCES WeightClasses(id) ON UPDATE CASCADE
);
	
CREATE TABLE Chats (
	from_user VARCHAR(50),
	to_user VARCHAR(50),
	time TIMESTAMP,
	message TEXT,
	PRIMARY KEY (from_user, to_user, time),
	FOREIGN KEY (from_user) REFERENCES Users (username) ON DELETE CASCADE,
	FOREIGN KEY (to_user) REFERENCES Users (username) ON DELETE CASCADE
);
	

CREATE TABLE Availabilities (
	ctname VARCHAR(50), --username of caretaker who advertised this availability
	start_date DATE,
	end_date DATE,
	PRIMARY KEY (ctname, start_date, end_date),
	FOREIGN KEY (ctname) REFERENCES Caretakers(username) 	ON DELETE CASCADE
);

CREATE TABLE ServiceTypes (
	id INTEGER, 
	name TEXT,
	PRIMARY KEY (id)
);

/**
Services offered by care taker
**/
CREATE TABLE OfferedCares (
    ctname VARCHAR(50),
	pet_sid INTEGER,
	pet_wid INTEGER,
	service_type_id INTEGER,
	price NUMERIC(10,2),
	FOREIGN KEY (ctname) REFERENCES CareTakers(username) ON DELETE CASCADE,
	FOREIGN KEY (pet_sid) REFERENCES PetSpecies(id) ON UPDATE CASCADE,
	FOREIGN KEY (pet_wid) REFERENCES WeightClasses(id) ON UPDATE CASCADE,
	FOREIGN KEY (service_type_id) REFERENCES ServiceTypes (id) ON UPDATE CASCADE,
	PRIMARY KEY (ctname, pet_sid, pet_wid, service_type_id) --All fields for now
);


CREATE TABLE Bids (
	id VARCHAR(50),
	oname VARCHAR(50),
	ctname VARCHAR(50),
	start_date DATE, --check that this start date is after the Availability's start date
	end_date DATE, --check that this end date if before the Availability's end date
	price NUMERIC(10,2),
	FOREIGN KEY (oname) REFERENCES Owners(username) ON DELETE CASCADE,
	FOREIGN KEY (ctname) REFERENCES Availabilities(ctname) ON DELETE CASCADE,
	PRIMARY KEY (id)
);

INSERT INTO Bids (id, oname, ctname, start_date, end_date, price) 
VALUES 
    (id, oname, ctname, start_date, end_date, price)

CREATE TABLE AcceptedBids (
	id VARCHAR(50),
    oname VARCHAR(50),
    availability_id INTEGER, --we can obtain information about caretaker from here
	start_date DATE, --check that this start date is after the Availability's start date
	end_date DATE, --check that this end date if before the Availability's end date
	price NUMERIC(10,2),
	FOREIGN KEY (oname) REFERENCES Owners(username) ON DELETE CASCADE,
	FOREIGN KEY (availability_id) REFERENCES Availabilities(id) ON DELETE CASCADE,
	PRIMARY KEY (id)
);

/*
 * Not complete yet
 */
CREATE TABLE Payments (
    abid_id VARCHAR(50),
    price NUMERIC(10,2), --10 digits, 2 of which are decimal
    FOREIGN KEY (abid_id) REFERENCES AcceptedBids(id) ON DELETE CASCADE
);

CREATE TABLE Reviews (
    abid_id VARCHAR(50),
    orating INTEGER, --rating that the caretaker gave the owner from 1 to 5
	caretaker_rating INTEGER, --rating that the owner gave the caretaker from 1 to 5
	ocomments TEXT, --comments that the caretaker gave the owner
	ctcomments TEXT, --comments that the owner gave the caretaker
	FOREIGN KEY (abid_id) REFERENCES AcceptedBids(id) ON DELETE CASCADE,
	PRIMARY KEY (abid_id)
);

INSERT INTO Users (username, email, password, phone_number)
VALUES 
    ('Alice00', 'alice00@hotmail.com', 'aliceisalice', 11111111),
    ('Bob00', 'bob00@hotmail.com', 'bobisbob', 11111112),
	('Clay00', 'clay00@hotmail.com', 'clayisclay', 11111113),
    ('Davis00', 'davis00@hotmail.com', 'davisisdavis', 11111114),
	('Eve00', 'eve00@hotmail.com', 'eveiseve', 11111115),
	('FeCl00', 'fecl00@hotmail.com', 'feclisfecl', 11111116),
	('Mallory00', 'mallory00@hotmail.com', 'malloryismallory', 11111117),
	('Sybil00', 'sybil00@hotmail.com', 'sybilissybil', 11111118);


INSERT INTO Owners (username)
VALUES 
    ('Alice00'),
	('Bob00'),
	('Clay00'),
	('Davis00'),
	('Eve00');


INSERT INTO Caretakers (username)
VALUES 
    ('Davis00'),
	('Eve00'),
	('FeCl00'),
	('Mallory00'),
	('Sybil00');


INSERT INTO PetSpecies (id, species) 
VALUES 
    (1, 'Cat'),
	(2, 'Dog');

INSERT INTO WeightClasses (id, weight_class) 
VALUES 
    (1, '0-7kg'),
	(2, '8-18kg'),
	(3, '19-45kg'),
	(4, '56kg+');

INSERT INTO Pets(pid, oname, pname, pet_sid, weight_class_id) 
VALUES 
    (1, 'Alice00', 'Prince', 1, 1),
	(2, 'Alice00', 'Princess', 2, 1),
	(1, 'Bob00', 'Orange', 2, 2),
	(2, 'Bob00', 'Purp', 1, 1),
	(1, 'Clay00', 'Processor', 2, 1),
	(2, 'Clay00', 'Harddrive', 1, 2),
	(3, 'Clay00', 'Compiler', 2, 2);

INSERT INTO Availabilities (ctname, start_date, end_date) 
VALUES
    ('Davis00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-31', 'YYYY-MM-DD')),
	('Eve00', to_date('2019-05-01', 'YYYY-MM-DD'), to_date('2019-05-20', 'YYYY-MM-DD')),
	('Mallory00', to_date('2019-04-19', 'YYYY-MM-DD'), to_date('2019-05-06', 'YYYY-MM-DD')),
	('Mallory00', to_date('2019-05-08', 'YYYY-MM-DD'), to_date('2019-06-20', 'YYYY-MM-DD')),
	('Mallory00', to_date('2019-03-31', 'YYYY-MM-DD'), to_date('2019-07-31', 'YYYY-MM-DD'));

INSERT INTO ServiceTypes (id, name)
VALUES 
    (1, 'Boarding'),
	(2, 'House Sitting'),
	(3, 'Drop-In Visits'),
	(4, 'Walking'),
	(5, 'Day Care');



INSERT INTO OfferedCares(ctname, pet_sid, pet_wid, service_type_id, price) 
VALUES 
    ('Davis00', 2, 1, 1, 20.00),
	('Davis00', 2, 1, 2, 15.00),
	('Davis00', 2, 1, 3, 15.00),
	('Davis00', 2, 1, 4, 15.00),
	('Davis00', 2, 1, 5, 10.00),
	('Davis00', 2, 2, 1, 24.00),
	('Davis00', 2, 2, 2, 20.00),
	('Davis00', 1, 1, 1, 18.00),
	('Davis00', 1, 2, 1, 20.00),
	('Davis00', 1, 1, 2, 18.00),
	('Davis00', 1, 1, 3, 19.00),
	('Davis00', 1, 1, 4, 10.00),
	('Davis00', 1, 1, 5, 13.00),
	('Davis00', 1, 2, 2, 20.00),
	('Eve00', 2, 3, 1, 30.00),
	('Eve00', 2, 3, 2, 34.00),
	('Eve00', 2, 3, 3, 29.00),
	('Eve00', 2, 3, 4, 28.00),
	('Eve00', 2, 3, 5, 29.00),
	('Eve00', 2, 4, 1, 40.00),
	('Eve00', 2, 4, 2, 45.00),
	('Eve00', 2, 4, 3, 30.00),
	('Eve00', 2, 4, 4, 30.00),
	('Eve00', 2, 4, 5, 39.00),
	('Mallory00', 1, 1, 1, 35.00),
	('Mallory00', 1, 1, 2, 30.00),
	('Mallory00', 1, 1, 3, 20.00),
	('Mallory00', 1, 1, 4, 10.00),
	('Mallory00', 1, 1, 5, 30.00),
	('Mallory00', 1, 2, 2, 40.00),
	('Mallory00', 1, 2, 3, 35.00),
	('Mallory00', 1, 2, 5, 40.00),
	('Mallory00', 2, 1, 1, 35.00),
	('Mallory00', 2, 1, 2, 30.00),
	('Mallory00', 2, 1, 3, 20.00),
	('Mallory00', 2, 1, 4, 10.00),
	('Mallory00', 2, 1, 5, 20.00),
	('Mallory00', 2, 2, 1, 40.00),
	('Mallory00', 2, 2, 2, 35.00),
	('Mallory00', 2, 2, 3, 30.00),
	('Mallory00', 2, 2, 5, 40.00);
	