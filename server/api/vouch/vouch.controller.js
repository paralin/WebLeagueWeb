'use strict';

var _ = require('lodash');
var Vouch = require('./vouch.model');
var User = require('./../user/user.model');

exports.update = function(req, res) {
  //See if the user exists
  User.findOne({'steam.steamid': req.params.id}, function(err, user){
    if(err) { return handleError(res, err); }
    if(!user) {
      Vouch.findById(req.params.id, function(err, vouch){
        if(err) { return handleError(res, err); }
        if(!vouch){
          return res.send(404);
        }else{
          console.log(JSON.stringify(req.body.data));
          vouch = _.extend(vouch, req.body.data);
          console.log(JSON.stringify(vouch));
          vouch._id = req.params.id;
          for(var key in vouch)
            {
              if(vouch[key] && vouch[key].length == 0) vouch[key] = null;
            }

            var upd = vouch.toObject();
            delete upd["_id"];

            Vouch.update({_id: vouch._id}, upd, function(err){
              if(err) {
                console.log(err);
                return handleError(res, err);
              }
              return res.send(200);
            });
        }
      });
    }else{
      user.vouch = req.body.data;
      user.vouch._id = user.steam.steamid;
      if(user.vouch && user.vouch.name && user.vouch.name.length){
        user.profile.name = user.vouch.name;
      }else{
        user.profile.name = user.steam.personaname;
      }
      for(var key in user.vouch)
        {
          if(user.vouch[key] && user.vouch[key].length == 0) user.vouch[key] = null;
        }
        user.save(function(err){
          if(err) { return handleError(res, err); }
          return res.send(200);
        });
    }
  });
};

exports.show = function(req, res) {
  //See if the user exists
  User.findOne({'steam.steamid': req.params.id}, 'vouch', function(err, user){
    if(err) { return handleError(res, err); }
    if(!user) {
      Vouch.findById(req.params.id, function(err, vouch){
        if(err) { return handleError(res, err); }
        if(!vouch){
          return res.send(404);
        }else{
          return res.json(vouch);
        }
      });
    }else{
      return res.json(user.vouch);
    }
  });
};

exports.remove = function(req, res){
  //See if the user exists
  User.findOne({'steam.steamid': req.params.id}, 'vouch', function(err, user){
    if(err) { return handleError(res, err); }
    if(!user) {
      Vouch.findById(req.params.id, function(err, vouch){
        if(err) { return handleError(res, err); }
        if(!vouch){
          return res.send(404);
        }else{
          Vouch.remove({_id: vouch._id}, function(err){
            if(err) { return handleError(res, err); }
            return res.send(200);
          });
        }
      });
    }else{
      user.vouch = null;
      user.save(function(err){
        if(err) { return handleError(res, err); }
        else { return res.send(200); }
      });
    }
  });
};

exports.list = function(req, res){
  Vouch.find({}, function(err, vouches){
    if(err) { return handleError(res, err); }
    res.json(vouches);
  });
};

exports.listhuman = function(req, res){
  var vouches;
  Vouch.find({}, function(err, vos){
    if(err) { return handleError(res, err); }
    vouches = vos;
    User.find({vouch: {$ne: null}}, function(err, usrs)
              {
                if(err) { return handleError(res, err); }
                usrs.forEach(function(usr){
                  vouches.push(usr.vouch);
                });
                res.json(vouches);
              });
  });
};

exports.create = function(req, res) {
  //See if the user exists
  User.findOne({'steam.steamid': req.params.id}, 'vouch', function(err, user){
    if(err) { return handleError(res, err); }
    if(!user) {
      Vouch.findById(req.params.id, function(err, vouch){
        if(err) { return handleError(res, err); }
        if(!vouch){
          var nvouch = new Vouch({
            _id: req.params.id,
            name: "",
            avatar: "",
            teamname: "",
            teamavatar: ""
          });
          nvouch.save(function(err){
            if(err) { return handleError(res, err); }
            return res.json(nvouch);
          });
        }else{
          return res.json(vouch);
        }
      });
    }else{
      if(user.vouch && user.vouch._id){
        return handleError(res, "That user already is vouched.");
      }else{
        user.vouch = {
          _id: user.steam.steamid,
          name: null,
          avatar: null,
          teamname: null,
          teamavatar: null
        };
        user.save(function(err){
          if(err) { return handleError(res, err); }
          else { return res.json(user.vouch); }
        });
      }
    }
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
