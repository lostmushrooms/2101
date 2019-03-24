var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const user = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '********',
  port: 5432,
})

/* SQL Query */
var sql_query = 'INSERT INTO Users VALUES';

router.get('/',function (req, res, next) {
    res.render('register', {
        title : 'Register Page',
        email : 'Email'
    })
});

// POST
router.post('/', function(req, res, next) {
	// Retrieve Information
	var username  = req.body.userName;
	var email    = req.body.email;
	
	var password = req.body.password;
	var phoneNumber = req.body.phoneNumber;
	
	// Construct Specific SQL Query
	var insert_query = sql_query + "('" + username + "','" + email + "','" + password + "','" + phoneNumber + "')";
	
	user.query(insert_query, (err, data) => {
		if (err) {
			 res.render('register', {
        	title : 'Register Page',
        	email : 'Email already existed, please use another email for registration'
   		})
			 return
        }
		res.redirect('/dashboard');
	});
});

module.exports = router;
