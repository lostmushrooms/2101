const sql_query = require('../postgresql_scripts');
const passport = require('passport');
const bcrypt = require('bcrypt')

// Postgre SQL Connection
const { Pool } = require('pg');
const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
  //ssl: true
});

const round = 10;
const salt  = bcrypt.genSaltSync(round);

function initRouter(app) {
	/* GET */
	
	/* PROTECTED GET */
	app.get('/'      , passport.antiMiddleware(), index );
	app.get('/index'      , passport.antiMiddleware(), index );
	app.get('/login' , passport.antiMiddleware(), login);
	app.get('/register' , passport.antiMiddleware(), register);
	app.get('/dashboard' , passport.authMiddleware(), dashboard);
	app.get('/makePost' , passport.authMiddleware(), makePost);
	app.get('/viewPost' , passport.authMiddleware(), viewPost);
	app.get('/placeBid' , passport.authMiddleware(), placeBid);
	app.get('/my_availabilities', passport.authMiddleware(), my_availabilities);
	app.get('/viewBids', passport.authMiddleware(), viewBids);
	app.get('/placedBids', passport.authMiddleware(), placedBids);
	app.get('/ownerAcceptedBids', passport.authMiddleware(), ownerAcceptedBids);
	
	/* PROTECTED POST */
	app.post('/register'   , passport.antiMiddleware(), reg_user);
	app.post('/placeBid' , passport.authMiddleware(), place_bid);
	app.post('/acceptBid' , passport.authMiddleware(), accept_bid);
	app.post('/makePost'   , passport.authMiddleware(), make_post);

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
		phone_number : req.user.phone_number,
		userType: req.user.userType
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
	basic(req, res, 'dashboard', { 
		info_msg: msg(req, 'info', 'Information updated successfully', 'Error in updating information'), 
		pass_msg: msg(req, 'pass', 'Password updated successfully', 'Error in updating password'), 
		auth: true 
	});
}

function makePost(req, res, next) {
	if (req.user.userType == "careTaker") {
		res.render('makePost', { page: 'makePost', auth: true });
	} else {
		res.redirect('/dashboard');
	}
}

function placeBid(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('/dashboard');
	}
	res.render('placeBid', { page: 'placeBid', auth: true, ctname: req.query.ctname, ctstart: req.query.startD, ctend: req.query.endD, aid: req.query.aid });
}

function viewBids(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var ctx = 0, tbl;
	pool.query(sql_query.query.single_avail_bids, [req.query.aid], (err, data) => {
		var id = null;
		var row = data.rows[0];
		if (row) {
			id = row.id;
		}
		console.log(data.rows[0]);
		if(err || !data.rows || data.rows.length == 0) {
			ctx = 0;
			tbl = [];
		} else {
			ctx = data.rows.length;
			tbl = data.rows;
		}
		basic(req, res, 'viewBids', { ctx: ctx, tbl: tbl, auth: true, bid: id});
	});
}

function my_availabilities(req, res, next) {
	var ctx = 0, tbl;
	console.log(req.user.user);
	pool.query(sql_query.query.my_avail, [req.user.username], (err, data) => {
		if(err || !data.rows || data.rows.length == 0) {
			ctx = 0;
			tbl = [];
		} else {
			ctx = data.rows.length;
			tbl = data.rows;
		}
		basic(req, res, 'my_availabilities', { ctx: ctx, tbl: tbl, auth: true });
	});
}

function viewPost(req, res, next) {
	var ctx = 0, idx = 0, tbl, total;
	if(Object.keys(req.query).length > 0 && req.query.p) {
		idx = req.query.p-1;
	}
	pool.query(sql_query.query.page_lims, [idx*10], (err, data) => {
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			tbl = data.rows;
		}
		pool.query(sql_query.query.ctx_posts, (err, data) => {
			if(err || !data.rows || data.rows.length == 0) {
				ctx = 0;
			} else {
				ctx = data.rows[0].count;
			}
			total = ctx%10 == 0 ? ctx/10 : (ctx - (ctx%10))/10 + 1;
			console.log(idx*10, idx*10+10, total);
			if(req.user.userType != "owner") {
				console.log(req.user);
				res.redirect('/dashboard');
			} else {
				basic(req, res, 'viewPost', { page: 'viewPost', auth: true, tbl: tbl, ctx: ctx, p: idx+1, t: total });
			}
		});
	});
}

function placedBids(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.placed_bids, [req.user.username], (err, data) => {
		var id = null;
		var row = data.rows[0];
		if (row) {
			id = row.id;
		}
		console.log(data.rows[0]);
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			tbl = data.rows;
		}
		basic(req, res, 'placedBids', { tbl: tbl, auth: true, p: 1});
	});
}

function ownerAcceptedBids(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.owner_accepted_bids, [req.user.username], (err, data) => {
		var id = null;
		var row = data.rows[0];
		if (row) {
			id = row.id;
		}
		console.log(data.rows[0]);
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			tbl = data.rows;
		}
		basic(req, res, 'ownerAcceptedBids', { tbl: tbl, auth: true});
	});
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
			if (userType == "careTaker") {
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
				userType: userType
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

function make_post(req, res, next) {
	var start  = req.body.datetimepicker6;
	var end  = req.body.datetimepicker7;
	var username = req.user.username;
	pool.query(sql_query.query.add_availability, [username,start,end], (err, data) => {
		if(err) {
			console.error("Error in adding post", err);
			res.redirect('/makePost?post=fail');
		} else {
			res.redirect('/dashboard');
		}
	});
}

function place_bid(req, res, next) {
	var start  = req.body.datetimepicker6;
	var end  = req.body.datetimepicker7;
	var oname = req.user.username;
	var price = req.body.price;
	var ctstart = req.body.ctstart;
	ctstart = new Date(ctstart);
	var ctend = req.body.ctend;
	ctend = new Date(ctend);
	var ctname = req.body.ctname;
	var availabilityid = req.body.aid;
	pool.query(sql_query.query.add_bid, [availabilityid, oname,start,end,price], (err, data) => {
		if(err) {
			console.error("Error in adding bid", err);
			res.redirect('/viewPost');
		} else {
			res.redirect('/dashboard');
		}
	});
}

function accept_bid(req, res, next) {
	var id  = req.body.bid;
	pool.query(sql_query.query.accept_bid, [id], (err, data) => {
		if(err) {
			console.error("Error in acceptbid " + id, err);
			res.redirect('/dashboard');
		} else {
			res.redirect('/dashboard');
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