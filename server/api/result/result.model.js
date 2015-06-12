'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');

var ResultSchema = mongoose.Schema({
  _id: Number,
  Result: Number,
  MatchId: String,
  DateFinished: Date,
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
  RatingDelta: Number,
  Match: {},
  MatchCounted: Boolean,
  League: String,
  LeagueSeason: Number,
  LeagueSecondarySeasons: [Number],

});

module.exports = mongoose.model('results', ResultSchema, "matchResults");
