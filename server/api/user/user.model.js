'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');

var UserSchema = mongoose.Schema({
  _id: String,
  authItems: [String],
  profile: {
    name: String,
    leagues: Object,
    /* "leagueid:seasonid": {
      rating: Number,
      wins: Number,
      losses: Number,
      abandons: Number,
      winStreak: Number,
      lossStreak: Number,
      lastGame: Date,
      decaySinceLast: Number
    }
   */
  },
  vouch: {
    _id: String,
    name: String,
    avatar: String,
    leagues: [String]
  },
  steam: {
    steamid: String,
    communityvisibilitystate: Number,
    profilestate: Number,
    personaname: String,
    lastlogoff: Number,
    commentpermission: Number,
    profileurl: String,
    avatar: String,
    avatarmedium: String,
    avatarfull: String,
    personastate: Number,
    realname: String,
    primaryclanid: String,
    timecreated: Number,
    personastateflags: Number,
    gameextrainfo: String,
    gameid: String,
    loccountrycode: String,
    locstatecode: String,
    loccityid: Number
  },
  settings: {
    language: String,
    sounds: {},
    soundMuted: Boolean
  },
  channels: [String],
  tsuniqueids: [String],
  tsonetimeid: String,
  tsonline: Boolean
});

/**
 * Validations
 */

// Validate empty name
UserSchema
.path('profile.name')
.validate(function(name) {
  return name.match(/^\s+$/) === null;
}, 'Name must not be just whitespace.');

//Validate steam ID
UserSchema
.path('steam.steamid')
.validate(function(sid){
  return /\d{17}/g.test(sid);
}, 'SteamID is a 17 digit integer.');

// Validate steamid is not taken
UserSchema
  .path('steam.steamid')
  .validate(function(value, respond) {
    var self = this;
    this.constructor.findOne({'steam.steamid': value}, function(err, user) {
      if(err) throw err;
      if(user) {
        if(self.id === user.id) return respond(true);
        return respond(false);
      }
      respond(true);
    });
}, 'The specified steam ID is already registered.');

var validatePresenceOf = function(value) {
  return value && value.length;
};

/**
 * Pre-save hook
 */
UserSchema
.pre('save', function(next) {
  if (!this.isNew) return next();

  if (!validatePresenceOf(this.steam.steamid))
    next(new Error('Invalid steamid'));
  else
    next();
});

/**
 * Methods
 */
UserSchema.methods = {
};

module.exports = mongoose.model('users', UserSchema);
