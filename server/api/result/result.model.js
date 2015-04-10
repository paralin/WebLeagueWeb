'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');

var ResultSchema = mongoose.Schema({
  _id: Number,
  Result: Number,
  Players: [{
    SID: String,
    Name: String,
    Team: Number,
    IsCaptain: Boolean,
    IsLeaver: Boolean,
    LeaverReason: Number,
    RatingBefore: Number
  }],
  RatingDire: Number,
  RatingRadiant: Number,
  Match: {}
});

module.exports = mongoose.model('results', ResultSchema, "matchResults");
