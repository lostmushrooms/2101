const sql = {}

sql.query = {
	// Counting & Average
	
	// Information
	page_lims: 'SELECT * FROM Availabilities ORDER BY start_date ASC LIMIT 10 OFFSET $1',
	ctx_posts: 'SELECT COUNT(*) FROM Availabilities',
	page_lims_name: 'SELECT * FROM Availabilities WHERE ctname=$1 ORDER BY start_date ASC LIMIT 10 OFFSET $2',
	ctx_posts_name: 'SELECT COUNT(*) FROM Availabilities WHERE ctname=$1',
	page_lims_time: 'SELECT * FROM Availabilities WHERE (start_date<=$1 and end_date>=$2) ORDER BY start_date ASC LIMIT 10 OFFSET $3',
	ctx_posts_time: 'SELECT COUNT(*) FROM Availabilities WHERE (start_date<=$1 and end_date >= $2)',

	// Caretakers
	my_avail: 'SELECT * FROM Availabilities WHERE ctname=$1 ORDER BY start_date ASC',
	single_avail_bids: 'SELECT * FROM Bids WHERE availabilityId=$1 and id not in (SELECT id from AcceptedBids)',
	ct_accepted_bids: 'SELECT Bids.id as id, Bids.oname as oname, Bids.ostart_date as start, Bids.oend_date as end, Bids.bidded_price_per_hour as price FROM Availabilities inner join Bids on Availabilities.id = Bids.availabilityId WHERE Availabilities.ctname = $1 and Bids.id in (SELECT id FROM AcceptedBids)',
	completed_trans: 'SELECT Bids.id as id, Bids.oname as oname, Bids.ostart_date as start, Bids.oend_date as end, Bids.bidded_price_per_hour as price FROM Availabilities inner join Bids on Availabilities.id = Bids.availabilityId WHERE Availabilities.ctname = $1 and Bids.id in (SELECT id FROM Payments)',


	// Owners
	placed_bids: 'SELECT Availabilities.ctname as ctname, Bids.ostart_date as start, Bids.oend_date as end, Bids.bidded_price_per_hour as bidded_price_per_hour FROM Availabilities inner join Bids on Availabilities.id = Bids.availabilityId WHERE Bids.oname = $1',
	owner_accepted_bids: 'SELECT Bids.id as id, Availabilities.ctname as ctname, Bids.ostart_date as start, Bids.oend_date as end, Bids.bidded_price_per_hour as price FROM Availabilities inner join Bids on Availabilities.id = Bids.availabilityId WHERE Bids.oname = $1 and Bids.id in (SELECT id FROM AcceptedBids) and Bids.id not in (SELECT id from Payments)',
	owner_pets: 'SELECT pname, gender, species, weight_class FROM Pets where oname=$1',
	
	// Insertion
	add_user: 'INSERT INTO Users (username, password, email, phone_number) VALUES ($1,$2,$3,$4)',
	add_owner: 'INSERT INTO Owners (username) VALUES ($1)',
	add_caretaker: 'INSERT INTO Caretakers (username) VALUES ($1)',
	add_availability: 'INSERT INTO Availabilities (id, ctname, start_date, end_date) VALUES ((SELECT (COALESCE(MAX(id), 0)) from Availabilities)+1,$1,$2,$3)',
	add_bid: 'INSERT INTO Bids (id, availabilityid, oname,ostart_date, oend_date, bidded_price_per_hour) VALUES ((SELECT (COALESCE(MAX(id), 0)) from Bids)+1, $1,$2,$3,$4,$5)',
	accept_bid: 'INSERT INTO AcceptedBids (id) VALUES ($1)',
	add_payment: 'INSERT INTO Payments (payment_id, id, value) VALUES ((SELECT (COALESCE(MAX(payment_id), 0)) from Payments)+1, $1,$2)',

	// UpsRW
	update_acceptedBid_owner: 'UPDATE AcceptedBids SET ctrating=($1), ocomments=($2) WHERE id=($3)',

	// Login
	userpass: 'SELECT * FROM Users WHERE username=$1',
	ownerpass: 'SELECT * FROM Owners WHERE username=$1',
	caretakerpass: 'SELECT * FROM Caretakers WHERE username=$1',
	
	// Update
	
	// Search
}

module.exports = sql