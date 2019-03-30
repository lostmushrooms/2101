const sql = {}

sql.query = {
	// Counting & Average
	
	// Information
	page_lims: 'SELECT * FROM Availabilities ORDER BY start_date ASC LIMIT 10 OFFSET $1',
	ctx_posts: 'SELECT COUNT(*) FROM Availabilities',
	
	// Insertion
	add_user: 'INSERT INTO Users (username, password, email, phone_number) VALUES ($1,$2,$3,$4)',
	add_owner: 'INSERT INTO Owners (username) VALUES ($1)',
	add_caretaker: 'INSERT INTO Caretakers (username) VALUES ($1)',
	add_availability: 'INSERT INTO Availabilities (ctname, start_date, end_date) VALUES ($1,$2,$3)',

	// Login
	userpass: 'SELECT * FROM Users WHERE username=$1',
	ownerpass: 'SELECT * FROM Owners WHERE username=$1',
	caretakerpass: 'SELECT * FROM Caretakers WHERE username=$1',
	
	// Update
	
	// Search

}

module.exports = sql