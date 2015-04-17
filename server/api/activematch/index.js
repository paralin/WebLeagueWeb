'use strict';

var express = require('express');
var controller = require('./activematch.controller');
var _ = require('lodash');

var router = express.Router();

function isAuthenticated(req, res, next){
  if(req.user){
    next();
  }else{
    res.status(401).json({status: 401, error: "not authenticated"});
  }
}

router.get('/', controller.index);

module.exports = router;
