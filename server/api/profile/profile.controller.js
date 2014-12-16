'use strict';

var _ = require('lodash');
var User = require('../user/user.model');

var selection = {'profile': 1, 'steam.avatarfull': 1, 'steam.steamid': 1, 'steam.profileurl': 1, 'vouch': 1};

// Get list of profiles
exports.index = function(req, res) {
  User.find({}).select(selection).exec(function (err, profiles) {
    if(err) { return handleError(res, err); }
    return res.status(200).json(profiles);
  });
};

exports.indexLeader = function(req, res) {
  User.find({vouch: {$exists: true}, "vouch._id": {$exists: true}}).select(selection).exec(function (err, profiles) {
    if(err) { return handleError(res, err); }
    return res.status(200).json(profiles);
  });
};

// Get a single profile
exports.show = function(req, res) {
  var id = req.params.id;
  if(id === "me"){
    id = req.user._id;
  }
  console.log(id);
  if(id === "leader"){
      return exports.indexLeader(req, res);
  }
  User.findOne({_id: id}, selection, function (err, profile) {
    if(err) { console.log(err); return handleError(res, err); }
    if(!profile) { return res.send(404); }
    return res.json(profile);
  });
};

function handleError(res, err) {
    return res.send(500, err);
}
