var session = require('express-session');
var MongoStore = require('connect-mongo')(session);
var cookieParser = require('cookie-parser');
var passport = require('passport');
var config = require('./environment');
var mongoose = require('mongoose');

module.exports = function(app){
  app.use(cookieParser(config.secrets.session));
  app.use(session({
    secret: config.secrets.session,
    cookie: {
      maxAge: 604800000
    },
    store: new MongoStore({
      mongooseConnection: mongoose.connection
    }),
    saveUninitialized: true,
    resave: true
  }));
  app.use(passport.initialize());
  app.use(passport.session());
};
