function antiMiddleware () {
  return function (req, res, next) {
    if (!req.isAuthenticated()) {
      return next()
    }
    res.redirect('/index')
  }
}

module.exports = antiMiddleware