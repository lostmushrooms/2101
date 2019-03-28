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