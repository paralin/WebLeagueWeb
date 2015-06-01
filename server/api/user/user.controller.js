'use strict';

var User = require('./user.model');
var passport = require('passport');
var config = require('../../config/environment');
var jwt = require('jsonwebtoken');
var chance = require('chance');
var build_id = require('../../version');

var validationError = function(res, err) {
  return res.json(422, err);
};

exports.status = function(req, res){
  var resp = {};
  resp.isAuthed = req.user != null;
  if(req.user){
    resp.sessID = req.sessionID;
    req.user.profile.winStreak = req.user.profile.winStreak || 0;
    if(!req.user.tsonetimeid)
    {
      req.user.tsonetimeid = (new chance()).word({syllables: 5});
      req.user.save(function(err){
        if(err) console.log("Can't save tsonetimeid, "+err);
      });
    }
    var user = {
      _id: req.user._id,
      steam: req.user.steam,
      profile: req.user.profile,
      authItems: req.user.authItems,
      vouch: req.user.vouch,
      settings: req.user.settings,
      tstoken: req.user.tsonetimeid,
      leagues: req.user.vouch.leagues
    };
    var profile = {
      _id: req.user._id,
      steamid: req.user.steam.steamid
    }
    resp.token = jwt.sign(profile, config.secrets.session, {algorithm:'HS256'});//{expiresInMinutes: 5});
    resp.server = config.networkServer;
    resp.user = user;
    resp.build_id = build_id;
  }
  res.json(resp);
};

exports.saveSettings = function(req, res)
{
  // Validate login
  if(req.user && req.body)
  {
    req.user.settings = req.body;
    User.update({_id: req.user._id}, {$set: {settings: req.body}}, function(err, user){
      if(err)
      {
        res.json(500, {error: 500, text: "internal server error"});
        return;
      }
      exports.status(req, res);
    });
  }
  else
  {
    res.json(430, {error: 430, text: "unauthorized"});
  }
};
