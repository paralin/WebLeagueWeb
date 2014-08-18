'use strict';

var express = require('express');
var config = require('../config/environment');
var User = require('../api/user/user.model');

// Passport Configuration
require('./steam/passport').setup(User, config);

var router = express.Router();

router.use('/steam', require('./steam'));
router.use('/logout', require('./logout'));

module.exports = router;
