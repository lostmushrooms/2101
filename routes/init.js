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
	
	// owner
	app.get('/viewPost' , passport.authMiddleware(), viewPost);
	app.get('/placeBid' , passport.authMiddleware(), placeBid);
	app.get('/viewBids', passport.authMiddleware(), viewBids);
	app.get('/placedBids', passport.authMiddleware(), placedBids);
	app.get('/ownerAcceptedBids', passport.authMiddleware(), ownerAcceptedBids);
	app.get('/pets', passport.authMiddleware(), Pets);
	app.get('/makePayment', passport.authMiddleware(), makePayment);
	app.get('/makeRating', passport.authMiddleware(), makeRating);
	app.get('/ctProfile', passport.authMiddleware(), ctProfile);
	app.get('/ownerCompletedTrans', passport.authMiddleware(), ownerCompletedTrans);

	//ct
	app.get('/makePost' , passport.authMiddleware(), makePost);
	app.get('/my_availabilities', passport.authMiddleware(), my_availabilities);
	app.get('/ctAcceptedBids', passport.authMiddleware(), ctAcceptedBids);
	app.get('/completedTrans', passport.authMiddleware(), completedTrans);
	app.get('/ownerProfile', passport.authMiddleware(), ownerProfile);
	app.get('/trueCompletedTrans', passport.authMiddleware(), trueCompletedTrans);
	app.get('/careProvided', passport.authMiddleware(), careProvided);

	//chat
	app.post('/send_message', passport.authMiddleware(), send_message);
	app.get('/viewMessages', passport.authMiddleware(), viewMessages);
	
	/* PROTECTED POST */
	app.post('/register'   , passport.antiMiddleware(), reg_user);
	app.post('/placeBid' , passport.authMiddleware(), place_bid);
	app.post('/acceptBid' , passport.authMiddleware(), accept_bid);
	app.post('/makePost'   , passport.authMiddleware(), make_post);
	app.post('/makePayment'   , passport.authMiddleware(), make_payment);
	app.post('/makeRating'   , passport.authMiddleware(), make_rating);
	app.post('/filterByName'   , passport.authMiddleware(), search_ct);
	app.post('/filterByDate'   , passport.authMiddleware(), search_date);
	app.post('/cleanFilter'   , passport.authMiddleware(), clean_filter);
	app.post('/closePost'   , passport.authMiddleware(), close_post);
	app.post('/add_pet'   , passport.authMiddleware(), add_pet);
	app.post('/delete_pet'   , passport.authMiddleware(), delete_pet);
	app.post('/add_care'   , passport.authMiddleware(), add_care);
	app.post('/delete_care'   , passport.authMiddleware(), delete_care);


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
	if (req.user.userType == "careTaker") {
		basic(req, res, 'caretakerdashboard', { 
			info_msg: msg(req, 'info', 'Information updated successfully', 'Error in updating information'), 
			pass_msg: msg(req, 'pass', 'Password updated successfully', 'Error in updating password'), 
			auth: true 
		});
	} else if (req.user.userType == "owner") {
		basic(req, res, 'ownerdashboard', { 
			info_msg: msg(req, 'info', 'Information updated successfully', 'Error in updating information'), 
			pass_msg: msg(req, 'pass', 'Password updated successfully', 'Error in updating password'), 
			auth: true 
		});
	} else {
		res.redirect("/")
	}
}

function makePost(req, res, next) {
	if (req.user.userType == "careTaker") {
		res.render('makePost', { user: req.user.username, page: 'makePost', auth: true });
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

function makePayment(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('/dashboard');
	}
	res.render('makePayment', { page: 'makePayment', auth: true, bid: req.query.bid, price: req.query.price});
}

function makeRating(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('/dashboard');
	}
	res.render('makeRating', { page: 'makeRating', auth: true, bid: req.query.bid, price: req.query.price});
}

function viewBids(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var ctx = 0, tbl;
	pool.query(sql_query.query.single_avail_bids, [req.query.aid], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			ctx = 0;
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			ctx = data.rows.length;
			tbl = data.rows;
		}
		basic(req, res, 'viewBids', { ctx: ctx, tbl: tbl, auth: true, bid: id});
	});
}

function Pets(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var len, tbl;
	pool.query(sql_query.query.owner_pets, [req.user.username], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			len = 0;
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			len = data.rows.length;
			tbl = data.rows;
		}
		basic(req, res, 'Pets', { tbl: tbl, len: len, auth: true, bid: id});
	});
}


function careProvided(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.care_provided, [req.user.username], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'careProvided', { tbl: tbl, auth: true, bid: id});
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

function viewMessages(req, res, next) {
	var tbl;
	if (req.user.userType == "owner") {
		pool.query(sql_query.query.read_message_owner, [req.user.username], (err, data) => {
			if(err || !data.rows || data.rows.length == 0) {
				tbl = [];
			} else {
				tbl = data.rows;
			}
			basic(req, res, 'viewMessages', { tbl: tbl, auth: true });
		});
	} else {
		pool.query(sql_query.query.read_message_ct, [req.user.username], (err, data) => {
			if(err || !data.rows || data.rows.length == 0) {
				tbl = [];
			} else {
				tbl = data.rows;
			}
			basic(req, res, 'viewMessages', { tbl: tbl, auth: true });
		});
	}
}

function viewPost(req, res, next) {
	var ctx = 0, idx = 0, tbl, total;
	if(Object.keys(req.query).length > 0 && req.query.p) {
		idx = req.query.p-1;
	}
	if (req.query.dstart && req.query.dend) {
		console.log(req.query.dstart);
		console.log(req.query.dend);
		var start = new Date(req.query.dstart);
		var end = new Date(req.query.dend);

		pool.query(sql_query.query.page_lims_time, [start, end, idx*10], (err, data) => {
			if(err || !data.rows || data.rows.length == 0) {
				console.log(err);
				tbl = [];
			} else {
				console.log(data.rows);
				tbl = data.rows;
			}
			pool.query(sql_query.query.ctx_posts_time, [req.query.dstart, req.query.dend], (err, data) => {
				if(err || !data.rows || data.rows.length == 0) {
					ctx = 0;
				} else {
					ctx = data.rows[0].count;
				}
				total = ctx%10 == 0 ? ctx/10 : (ctx - (ctx%10))/10 + 1;
				console.log(idx*10, idx*10+10, total);
				if(req.user.userType != "owner") {
					res.redirect('/dashboard');
				} else {
					basic(req, res, 'viewPost', { page: 'viewPost', auth: true, tbl: tbl, ctx: ctx, p: idx+1, t: total, ctname: req.query.ctname });
				}
			});
		});
		return;
	}
	if (req.query.ctname) {
		pool.query(sql_query.query.page_lims_name, [req.query.ctname, idx*10], (err, data) => {
			if(err || !data.rows || data.rows.length == 0) {
				tbl = [];
			} else {
				tbl = data.rows;
			}
			pool.query(sql_query.query.ctx_posts_name, [req.query.ctname], (err, data) => {
				if(err || !data.rows || data.rows.length == 0) {
					ctx = 0;
				} else {
					ctx = data.rows[0].count;
				}
				total = ctx%10 == 0 ? ctx/10 : (ctx - (ctx%10))/10 + 1;
				console.log(idx*10, idx*10+10, total);
				if(req.user.userType != "owner") {
					res.redirect('/dashboard');
				} else {
					basic(req, res, 'viewPost', { page: 'viewPost', auth: true, tbl: tbl, ctx: ctx, p: idx+1, t: total, ctname: req.query.ctname });
				}
			});
		});
		return;
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
				res.redirect('/dashboard');
			} else {
				basic(req, res, 'viewPost', { page: 'viewPost', auth: true, tbl: tbl, ctx: ctx, p: idx+1, t: total });
			}
		});
	});
}

function search_ct(req, res, next) {
	res.redirect('/viewPost?ctname='+req.body.ctname);
}

function search_date(req, res, next) {
	var start  = req.body.datetimepicker6;
	var end  = req.body.datetimepicker7;
	res.redirect('/viewPost?dstart='+start+'&dend='+end);
}

function clean_filter(req, res, next) {
	res.redirect('/viewPost');
}

function placedBids(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.placed_bids, [req.user.username], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'placedBids', { tbl: tbl, auth: true, p: 1});
	});
}

function ctProfile(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var care, tbl;
	pool.query(sql_query.query.ct_care, [req.query.ctname], (err, data) => {
		console.log(data.rows[0]);
		if(err || !data.rows || data.rows.length == 0) {
			care = [];
		} else {
			care = data.rows;
		}

		pool.query(sql_query.query.ct_comments, [req.query.ctname], (err, data) => {
			console.log(data.rows[0]);
			if(err || !data.rows || data.rows.length == 0) {
				tbl = [];
			} else {
				tbl = data.rows;
			}
			basic(req, res, 'ctProfile', { ctname: req.query.ctname, tbl: tbl, care: care, auth: true});
		});
	});
}


function ownerProfile(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var pets, tbl;
	pool.query(sql_query.query.owner_pets, [req.query.oname], (err, data) => {
		console.log(data.rows[0]);
		if(err || !data.rows || data.rows.length == 0) {
			pets = [];
		} else {
			pets = data.rows;
		}

		pool.query(sql_query.query.owner_comments, [req.query.oname], (err, data) => {
			console.log(data.rows[0]);
			if(err || !data.rows || data.rows.length == 0) {
				tbl = [];
			} else {
				tbl = data.rows;
			}
			basic(req, res, 'ownerProfile', { oname: req.query.oname, tbl: tbl, pets: pets, auth: true});
		});
	});
}

function ownerAcceptedBids(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.owner_accepted_bids, [req.user.username], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'ownerAcceptedBids', { tbl: tbl, auth: true});
	});
}

function ctAcceptedBids(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.ct_accepted_bids, [req.user.username], (err, data) => {
		var id = null;
		var row = null;
		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'ctAcceptedBids', { tbl: tbl, auth: true});
	});
}


function completedTrans(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.completed_trans, [req.user.username], (err, data) => {
		var id = null;
		var row = null;

		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'completedTrans', { tbl: tbl, auth: true});
	});
}

function trueCompletedTrans(req, res, next) {
	if(req.user.userType != "careTaker") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.true_completed_trans, [req.user.username], (err, data) => {
		var id = null;
		var row = null;

		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'trueCompleteTrans', { tbl: tbl, auth: true});
	});
}

function ownerCompletedTrans(req, res, next) {
	if(req.user.userType != "owner") {
		res.redirect('dashboard');
	}
	var tbl;
	pool.query(sql_query.query.owner_completed_trans, [req.user.username], (err, data) => {
		var id = null;
		var row = null;

		if(err || !data.rows || data.rows.length == 0) {
			tbl = [];
		} else {
			row = data.rows[0];
			if (row) {
				id = row.id;
			}
			tbl = data.rows;
		}
		basic(req, res, 'ownerCompleteTrans', { tbl: tbl, auth: true});
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

function make_payment(req, res, next) {
	var bid  = req.body.bid;
	var price  = req.body.price;
	var rating = req.body.ctRating;
	var comment = req.body.ocomment;
	console.log(rating);
	console.log(comment);
	console.log(bid);
	console.log(price);
	pool.query(sql_query.query.add_payment, [bid,price], (err, data) => {
		if(err) {
			req.flash('message', "Error in adding payment");
			req.session.save(function () {
				res.redirect('/?pay=fail');
			});
		} else {
			pool.query(sql_query.query.update_acceptedBid_owner, [rating, comment, bid], (err, data) => {
				if(err) {
					res.redirect('/?pay=fail');
				} else {
					res.redirect('/');
				}
			});
		}
	});
}

function add_pet(req, res, next) {
	var oname = req.user.username;
	var name, gender, species, weight_class, bio;
	pname = req.body.petname;
	gender = req.body.gender;
	species = req.body.species;
	weight_class = req.body.weight_class;
	bio = req.body.description;
	pool.query(sql_query.query.add_pet, [oname, pname, gender, species, weight_class, bio], (err, data) => {
		if(err) {
			res.redirect('/');
		} else {
			res.redirect('/pets');
		}
	});
}


function add_care(req, res, next) {
	var ctname = req.user.username;
	var species, weight_class, service, bio;
	species = req.body.species;
	weight_class = req.body.weight_class;
	service = req.body.service;
	bio = req.body.description;
	pool.query(sql_query.query.add_care, [ctname, species, weight_class, service, bio], (err, data) => {
		if(err) {
			res.redirect('/');
		} else {
			res.redirect('/careProvided');
		}
	});
}


function send_message(req, res, next) {
	var oname, ctname, from_owner, message;
	message = req.body.message;
	if (req.user.userType == 'owner') {
		from_owner = true;
		oname = req.user.username;
		ctname = req.body.toname;
	} else {
		from_owner = false;
		oname = req.body.toname;
		ctname = req.user.username;
	}
	pool.query(sql_query.query.send_message, [oname, ctname, from_owner, message], (err, data) => {
		if(err) {
			res.redirect('/');
		} else {
			res.redirect('/');
		}
	});
}


function make_rating(req, res, next) {
	var bid  = req.body.bid;
	var rating = req.body.ctRating;
	var comment = req.body.ocomment;
	pool.query(sql_query.query.update_acceptedBid_caretaker, [rating, comment, bid], (err, data) => {
		if(err) {
			res.redirect('/?rate=fail');
		} else {
			res.redirect('/');
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

function close_post(req, res, next) {
	var id  = req.body.aid;
	pool.query(sql_query.query.close_post, [id], (err, data) => {
		if(err) {
			console.error("Error in close " + id, err);
			res.redirect('/dashboard');
		} else {
			res.redirect('/my_availabilities');
		}
	});
}

function delete_pet(req, res, next) {
	var pname = req.body.pname;
	var oname = req.user.username
	pool.query(sql_query.query.delete_pet, [pname, oname], (err, data) => {
		if(err) {
			console.error("Error in delete " + pname, err);
			res.redirect('/dashboard');
		} else {
			res.redirect('/Pets');
		}
	});
}

function delete_care(req, res, next) {
	var ctname = req.user.username;
	var species = req.body.species;
	var weight_class = req.body.weight_class;
	var service = req.body.service
	pool.query(sql_query.query.delete_care, [ctname, species, weight_class, service], (err, data) => {
		if(err) {
			console.error("Error in delete " + species, err);
			res.redirect('/dashboard');
		} else {
			res.redirect('/careProvided');
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