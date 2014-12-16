'use strict';

var express = require('express');
var controller = require('./vouch.controller');

var router = express.Router();
var _ = require('lodash');

function isAuthenticated(req, res, next){
  if(req.user && req.user.authItems && _.contains(req.user.authItems, "vouch")){
    next();
  }else{
    res.status(401);
  }
}

router.get('/get/:id', isAuthenticated, controller.show);
router.post('/delete/:id', isAuthenticated, controller.remove);
router.post('/update/:id', isAuthenticated, controller.update);
router.post('/:id', isAuthenticated, controller.create);

module.exports = router;
