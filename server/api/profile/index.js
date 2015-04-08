'use strict';

var express = require('express');
var controller = require('./profile.controller');
var _ = require('lodash');

var router = express.Router();

function isAuthenticated(req, res, next){
  if(req.user){
    next();
  }else{
    res.status(401).json({status: 401, error: "not authenticated"});
  }
}

router.get('/', isAuthenticated, controller.index);
router.get('/:id', isAuthenticated, controller.show);

module.exports = router;
