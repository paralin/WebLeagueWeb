'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var HeroSchema = mongoose.Schema({
  _id: Number,
  name: String,
  fullName: String
});

module.exports = mongoose.model('heros', HeroSchema);
