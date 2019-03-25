var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
   res.render('dashboard',{
        title : 'User List',
        username : req.session.username
    })
});

module.exports = router;
