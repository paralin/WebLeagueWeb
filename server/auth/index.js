'use strict';

var express = require('express');
var config = require('../config/environment');
var User = require('../api/user/user.model');
var Vouch = require('../api/vouch/vouch.model');

// Passport Configuration
require('./steam/passport').setup(User, Vouch, config);

var router = express.Router();

router.use('/steam', require('./steam'));
router.use('/logout', require('./logout'));

module.exports = router;
