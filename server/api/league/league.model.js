'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');

var LeagueSchema = mongoose.Schema({
  _id: String,
  Name: String,
  IsActive: Boolean,
  Archived: Boolean,
  CurrentSeason: Number,
  SecondaryCurrentSeason: [Number],
  Region: Number,
  Seasons: [{
    Name: String,
    Prizepool: Number,
    PrizepoolCurrency: String,
    PrizepoolDist: [Number],
    Start: Date,
    End: Date,
    Ticket: Number
  }],
  VouchPanel: Boolean,
  Decay: {
    DecayStart: Number,
    DecayRate: Number,
    LowerThreshold: Number
  }
});

module.exports = mongoose.model('leagues', LeagueSchema, "leagues");
