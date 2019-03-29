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

--A care taker should not have 2 availabilities, u and v where u.start_date < v.start_date but u.end_date >= v.start_date! This is an overlap and we will merge these 2 results to create
--another availability which includes both timeframes.



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
	ctstart_date DATE, 
	ctend_date DATE, 
	ostart_date DATE, --check that this start date is after the Availability's start date
	oend_date DATE, --check that this end date if before the Availability's end date
	price NUMERIC(10,2),
	FOREIGN KEY (oname) REFERENCES Owners(username) ON DELETE CASCADE,
	FOREIGN KEY (ctname, ctstart_date, ctend_date) REFERENCES Availabilities(ctname, start_date, end_date) ON DELETE CASCADE,
	PRIMARY KEY (id)
);

CREATE TABLE AcceptedBids (
	id VARCHAR(50),
	orating INTEGER, --rating that the caretaker gave the owner from 1 to 5
	ctrating INTEGER, --rating that the owner gave the caretaker from 1 to 5
	ocomments TEXT, --comments that the caretaker gave the owner
	ctcomments TEXT, --comments that the owner gave the caretaker
	FOREIGN KEY (id) REFERENCES Bids(id) ON DELETE CASCADE,
	PRIMARY KEY (id)
);

