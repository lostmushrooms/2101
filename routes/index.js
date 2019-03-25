var express = require('express');
var router = express.Router();
var passport = require('passport');

router.get('/', function(req, res, next) {
    res.render('index', {
        title: 'Express',
        message : req.flash('error').toString(),
        isLoggedIn: req.user
    });
});

router.get('/searchCaretaker', function (req, res, next) {
    res.render('searchCaretaker', {
        title : 'Search Caretaker'
    })
});

router.get('/beCaretaker', function (req, res, next) {
    res.render('beCaretaker', {
        title : 'Be A Caretaker'
    })
});

router.get('/profile', function (req, res, next) {
    res.render('profile', {
        title : 'My Profile'
    })
});

router.get('/logout', function(req, res) {
    req.logout();
    res.redirect('/');
});

function isLoggedIn(req, res, next) {
    if (req.session.username){
        return next();
    }
    res.redirect('/');
}

module.exports = router;