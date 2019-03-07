--drop tables first
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Owners CASCADE;
DROP TABLE IF EXISTS Caretakers CASCADE;
DROP TABLE IF EXISTS PetSpecies CASCADE;
DROP TABLE IF EXISTS WeightClasses CASCADE;
DROP TABLE IF EXISTS Pets CASCADE;
DROP TABLE IF EXISTS Chats CASCADE;
DROP TABLE IF EXISTS Availibity CASCADE; --just a rename of 'Annoucement' in our discussed schema


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
	id INTEGER, --uniquely identifies a species. i.e. id = 1 refers to Dog
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
	species_id INTEGER, --species of animal e.g. 1 refers to Dog
	breed VARCHAR(30), --breed of animal e.g. 'French Bulldog'. Assumed to make sense with species_id attribute.
	weight_class_id INTEGER, --refers to weight class e.g. 1 refers to <2.5kg
	PRIMARY KEY (pid, owner_username),
	FOREIGN KEY (owner_username) REFERENCES Users (username) ON DELETE CASCADE,
	FOREIGN KEY (species_id) REFERENCES PetSpecies(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (weight_class_id) REFERENCES WeightClasses(id) ON UPDATE CASCADE ON DELETE SET NULL
);
	
CREATE TABLE Chats (
	from_user VARCHAR(50),
	to_user VARCHAR(50),
	time TIMESTAMP,
	PRIMARY KEY (from_user, to_user, time),
	FOREIGN KEY (from_user) REFERENCES Users (username) ON DELETE CASCADE,
	FOREIGN KEY (to_user) REFERENCES Users (username) ON DELETE CASCADE
);
	
/* not done
CREATE TABLE Availability (
	username VARCHAR(50), --username of caretaker who advertised this availability
	start_date DATE,
	end_date DATE,
	
);
*/

	