'use strict';

var express = require('express');
var controller = require('./hero.controller');

var router = express.Router();

router.get('/:id(\\d+)/', controller.show);

controller.fetchHeros();

module.exports = router;
