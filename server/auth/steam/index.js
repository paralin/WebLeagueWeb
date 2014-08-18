'use strict';

var express = require('express');
var passport = require('passport');
var auth = require('../auth.service');

var router = express.Router();

router.get('/', passport.authenticate('steam', {failureRedirect: '/'}), function(req, res){ res.redirect('/'); });
router.get('/return', passport.authenticate('steam', {failureRedirect: '/'}), function(req, res){ res.redirect('/'); });

module.exports = router;
