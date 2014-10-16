'use strict';

var express = require('express');
var controller = require('./profile.controller');

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

module.exports = router;
