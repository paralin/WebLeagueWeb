'use strict';

var express = require('express');
var controller = require('./user.controller');
var config = require('../../config/environment');
var auth = require('../../auth/auth.service');

var router = express.Router();

function isAuthenticated(req, res, next){
  if(req.user){
    next();
  }else{
    res.json(401, {error: "not authorized"});
  }
}

router.get('/status', controller.status);
router.post('/saveSettings', isAuthenticated, controller.saveSettings);
router.post('/clearTsTokens', isAuthenticated, controller.clearTsIds);

module.exports = router;
