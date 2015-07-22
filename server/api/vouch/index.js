'use strict';

var express = require('express');
var controller = require('./vouch.controller');

var router = express.Router();
var _ = require('lodash');

function isAuthenticated(req, res, next){
  if(req.user && req.user.authItems && _.contains(req.user.authItems, "vouch")){
    next();
  }else{
    res.json(401, {error: "not authorized"});
  }
}

router.get('/get/:id', controller.show);
router.get('/list/', isAuthenticated, controller.list);
router.get('/listh/', isAuthenticated, controller.listhuman);
router.post('/delete/:id', isAuthenticated, controller.remove);
router.post('/update/:id', isAuthenticated, controller.update);
router.post('/create/:id', isAuthenticated, controller.create);

module.exports = router;
