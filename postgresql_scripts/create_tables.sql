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
	name VARCHAR(50), --non-unique name of user
	email VARCHAR(100) UNIQUE NOT NULL , --increase if necessary
	password VARCHAR(20) NOT NULL,
	phoneNumber VARCHAR(20),
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
	owner_username VARCHAR(50), --username of owner
	pname VARCHAR(50), --non-unique name of pet
	pet_sid INTEGER, --species of animal e.g. 1 refers to Dog
	--add breed as type string here maybe?
	weight_class_id INTEGER, --refers to weight class e.g. 1 refers to <2.5kg
	PRIMARY KEY (pid, owner_username),
	FOREIGN KEY (owner_username) REFERENCES Users (username) ON DELETE CASCADE,
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
    id INTEGER,
	username VARCHAR(50), --username of caretaker who advertised this availability
	start_date DATE,
	end_date DATE,
	PRIMARY KEY (id),
	FOREIGN KEY (username) REFERENCES Caretakers(username) 	ON DELETE CASCADE

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
	FOREIGN KEY (ctname) REFERENCES CareTakers(username) ON DELETE CASCADE,
	FOREIGN KEY (pet_sid) REFERENCES PetSpecies(id) ON UPDATE CASCADE,
	FOREIGN KEY (pet_wid) REFERENCES WeightClasses(id) ON UPDATE CASCADE,
	FOREIGN KEY (service_type_id) REFERENCES ServiceTypes (id) ON UPDATE CASCADE,
	PRIMARY KEY (ctname, pet_sid, pet_wid, service_type_id) --All fields for now
);

CREATE TABLE Bids (
	id INTEGER,
	owner_username VARCHAR(50),
    availability_id INTEGER, --we can obtain information about caretaker from here
	start_date DATE, --check that this start date is after the Availability's start date
	end_date DATE, --check that this end date if before the Availability's end date
	FOREIGN KEY (owner_username) REFERENCES Owners(username) ON DELETE CASCADE,
	FOREIGN KEY (availability_id) REFERENCES Availabilities(id) ON DELETE CASCADE,
	PRIMARY KEY (id)
);

CREATE TABLE AcceptedBids (
);

/*
 * Not complete yet
 */
CREATE TABLE Payments (
    bid_id INTEGER,
    price NUMERIC(10,2), --10 digits, 2 of which are decimal
    FOREIGN KEY (bid_id) REFERENCES AcceptedBids(id) ON DELETE CASCADE
);

CREATE TABLE Reviews (
    bid_id INTEGER,
    owner_rating INTEGER, --rating that the caretaker gave the owner from 1 to 5
	caretaker_rating INTEGER, --rating that the owner gave the caretaker from 1 to 5
	owner_comments TEXT, --comments that the caretaker gave the owner
	caretaker_comments TEXT, --comments that the owner gave the caretaker
	FOREIGN KEY (bid_id) REFERENCES AcceptedBids(id) ON DELETE CASCADE,
	PRIMARY KEY (bid_id)
);


	