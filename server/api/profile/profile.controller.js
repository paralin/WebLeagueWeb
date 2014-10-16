'use strict';

var _ = require('lodash');
var User = require('../user/user.model');

var selection = {'profile': 1, 'steam.avatarfull': 1, 'steam.steamid': 1, 'steam.profileurl': 1};

// Get list of profiles
exports.index = function(req, res) {
  User.find().select(selection).exec(function (err, profiles) {
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

// Updates an existing profile in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  User.findOne({_id: req.params.id}, selection, function (err, profile) {
    if (err) { return handleError(res, err); }
    if(!profile) { return res.send(404); }
    var updated = _.merge(profile, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, profile);
    });
  });
};

// Deletes a profile from the DB.
exports.destroy = function(req, res) {
  User.findOne({_id: req.params.id}, selection, function (err, profile) {
    if(err) { return handleError(res, err); }
    if(!profile) { return res.send(404); }
    profile.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
