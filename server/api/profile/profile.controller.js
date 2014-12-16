'use strict';

var _ = require('lodash');
var User = require('../user/user.model');

var selection = {'profile': 1, 'steam.avatarfull': 1, 'steam.steamid': 1, 'steam.profileurl': 1, 'vouch': 1};

// Get list of profiles
exports.index = function(req, res) {
  User.find({$exists: {'vouch': true}}).select(selection).exec(function (err, profiles) {
    if(err) { return handleError(res, err); }
    return res.json(200, profiles);
  });
};

// Get a single profile
exports.show = function(req, res) {
  var id = req.params.id;
  if(id === "me"){
    id = req.user._id;
  }
  User.findOne({_id: id}, selection, function (err, profile) {
    if(err) { return handleError(res, err); }
    if(!profile) { return res.send(404); }
    return res.json(profile);
  });
};

function handleError(res, err) {
    return res.send(500, err);
}
