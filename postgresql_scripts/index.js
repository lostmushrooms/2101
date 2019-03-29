const sql = {}

sql.query = {
	// Counting & Average
	
	// Information
	
	// Insertion
	add_user: 'INSERT INTO Users (username, password, email, phone_number) VALUES ($1,$2,$3,$4)',
	
	// Login
	userpass: 'SELECT * FROM Users WHERE username=$1',
	
	// Update
	
	// Search

}

module.exports = sql