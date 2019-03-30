const sql_query = require('../postgresql_scripts');

const passport = require('passport');
const bcrypt = require('bcrypt');
const LocalStrategy = require('passport-local').Strategy;

const authMiddleware = require('./middleware');
const antiMiddleware = require('./antimiddle');

// Postgre SQL Connection
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  //ssl: true
});

function findUser (username, callback) {
	pool.query(sql_query.query.userpass, [username], (err, data) => {
		if(err) {
			console.error("Cannot find user");
			return callback(null);
		}
		
		if(data.rows.length == 0) {
			console.error("User does not exists?");
			return callback(null)
		} else if(data.rows.length == 1) {
      findCareTaker(username, (err, user) => {
        if (err) {
          return done(err);
        }
        if (user) {
          return callback(null, {
            username    : data.rows[0].username,
            passwordHash: data.rows[0].password,
            email   : data.rows[0].email,
            phone_number: data.rows[0].phone_number,
            userType: user.userType
          });
        }
      });
      findOwner (username, (err, user) => {
        if (err) {
          return done(err);
        }
        if (user) {
          return callback(null, {
            username    : data.rows[0].username,
            passwordHash: data.rows[0].password,
            email   : data.rows[0].email,
            phone_number: data.rows[0].phone_number,
            userType: user.userType
          });
        }
      });
    }
    return callback(null);
  });
}

function findCareTaker (username, callback) {
  pool.query(sql_query.query.caretakerpass, [username], (err, data) => {
    if(err) {
      console.error("Cannot find user");
      return callback(null);
    }

    if(data.rows.length == 1) {
      return callback(null, {
        userType: "careTaker"
      });
    } else {
      console.error("More than one user?");
      return callback(null);
    }
  });
}

function findOwner (username, callback) {
  pool.query(sql_query.query.ownerpass, [username], (err, data) => {
    if(err) {
      console.error("Cannot find user");
      return callback(null);
    }

    if(data.rows.length == 1) {
      return callback(null, {
        userType: "owner"
      });
    }
  });
}

passport.serializeUser(function (user, cb) {
  cb(null, user.username);
})

passport.deserializeUser(function (username, cb) {
  findUser(username, cb);
})

function initPassport () {
  passport.use(new LocalStrategy(
    (username, password, done) => {
      findUser(username, (err, user) => {
        if (err) {
          return done(err);
        }

        // User not found
        if (!user) {
          console.error('User not found');
          return done(null, false);
        }

        // Always use hashed passwords and fixed time comparison
        bcrypt.compare(password, user.passwordHash, (err, isValid) => {
          if (err) {
            return done(err);
          }
          if (!isValid) {
            return done(null, false);
          }
          return done(null, user);
        })
      })
    }
    ));

  passport.authMiddleware = authMiddleware;
  passport.antiMiddleware = antiMiddleware;
  passport.findUser = findUser;
}

module.exports = initPassport;
