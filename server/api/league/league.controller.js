'use strict';

var _ = require('lodash');
var League = require('./league.model');

// Get list of leagues
exports.index = function(req, res) {
  League.find({Archived: false}).exec(function (err, results) {
    if(err) { return handleError(res, err); }
    return res.status(200).json(results);
  });
};

// Get a single league
exports.show = function(req, res) {
  var id = req.params.id;
  League.findOne({_id: id}, function (err, result) {
    if(err) { console.log(err); return handleError(res, err); }
    if(!result) { return res.send(404); }
    return res.json(result);
  });
};

function handleError(res, err) {
    return res.send(500, err);
}
