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
  Seasons: [{
    Name: String,
    Prizepool: Number,
    PrizepoolCurrency: String,
    Start: Date,
    End: Date,
    Ticket: Number
  }]
});

module.exports = mongoose.model('leagues', LeagueSchema, "leagues");
