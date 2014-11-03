'use strict';

var express = require('express');
var controller = require('./profile.controller');
var _ = require('lodash');

var router = express.Router();

function isAuthenticated(req, res, next){
  if(req.user){
    next();
  }else{
    res.status(401);
  }
}

router.get('/', isAuthenticated, controller.index);
router.get('/:id', isAuthenticated, controller.show);
router.post('/', isAuthenticated, controller.update);
router.delete('/:id', isAuthenticated, controller.destroy);
router.post('/devouch/:id', isAuthenticated, function(req,res,next){
    if(req.user && _.contains(req.user.authItems, 'vouch')){
        next();
    }else{
        res.status(403);
    }
}, controller.devouch);
router.post('/vouch/:id', isAuthenticated, function(req,res,next){
    if(req.user && _.contains(req.user.authItems, 'vouch')){
        next();
    }else{
        res.status(403);
    }
}, controller.vouch);

module.exports = router;
