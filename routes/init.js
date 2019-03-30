const sql_query = require('../postgresql_scripts');
const passport = require('passport');
const bcrypt = require('bcrypt')

// Postgre SQL Connection
const { Pool } = require('pg');
const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
  //ssl: true
});

// The following is example code from Prof
// can use this style to link js and sql

const round = 10;
const salt  = bcrypt.genSaltSync(round);

function initRouter(app) {
	/* GET */
	
	/* PROTECTED GET */
	app.get('/'      , passport.antiMiddleware(), index );
	app.get('/login' , passport.antiMiddleware(), login);
	app.get('/register' , passport.antiMiddleware(), register);
	app.get('/dashboard' , passport.authMiddleware(), dashboard);
	
	/* PROTECTED POST */
	app.post('/register'   , passport.antiMiddleware(), reg_user);

	/* LOGIN */
	app.post('/login', passport.authenticate('local', {
		successRedirect: '/dashboard',
		failureRedirect: '/'
	}));
	
	/* LOGOUT */
	app.get('/logout', passport.authMiddleware(), logout);
}


// Render Function
function basic(req, res, page, other) {
	var info = {
		page: page,
		user: req.user.username,
		email: req.user.email,
		phone_number : req.user.phone_number
	};
	if(other) {
		for(var fld in other) {
			info[fld] = other[fld];
		}
	}
	res.render(page, info);
}
function query(req, fld) {
	return req.query[fld] ? req.query[fld] : '';
}
function msg(req, fld, pass, fail) {
	var info = query(req, fld);
	return info ? (info=='pass' ? pass : fail) : '';
}

// GET
function index(req, res, next) {
	res.render('index', { page: 'index', auth: false });
}

function register(req, res, next) {
	res.render('register', { page: 'register', auth: false });
}

function dashboard(req, res, next) {
	basic(req, res, 'dashboard', { info_msg: msg(req, 'info', 'Information updated successfully', 'Error in updating information'), pass_msg: msg(req, 'pass', 'Password updated successfully', 'Error in updating password'), auth: true });
}

function login(req, res, next) {
	res.render('login', { page: 'login', auth: false });
}

function reg_user(req, res, next) {
	var username  = req.body.username;
	var password  = bcrypt.hashSync(req.body.password, salt);
	var email = req.body.email;
	var phoneNumber  = req.body.phoneNumber;
	var userType = req.body.userType;
	pool.query(sql_query.query.add_user, [username,password,email,phoneNumber], (err, data) => {
		if(err) {
			console.error("Error in adding user", err);
			res.redirect('/register?reg=fail');
		} else {
			if (userType = "careTaker") {
				pool.query(sql_query.query.add_caretaker, [username], (err, data) => {
					if(err) {
						console.error("Error in adding user", err);
						res.redirect('/register?reg=fail');
						return;
					}
				});
			} else {
				pool.query(sql_query.query.add_owner, [username], (err, data) => {
					if(err) {
						console.error("Error in adding user", err);
						res.redirect('/register?reg=fail');
						return;
					}
				});
			}
			req.login({
				username    : username,
				passwordHash: password,
				email   : email,
				phone_number    : phoneNumber,
				userType: userType,
			}, function(err) {
				if(err) {
					return res.redirect('/register?reg=fail');
				} else {
					return res.redirect('/dashboard');
				}
			});
		}
	});
}

// LOGOUT
function logout(req, res, next) {
	req.session.destroy()
	req.logout()
	res.redirect('/')
}

module.exports = initRouter;