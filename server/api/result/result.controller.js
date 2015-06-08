'use strict';

var _ = require('lodash');
var Result = require('../result/result.model');

// Get list of results
exports.index = function(req, res) {
  Result.find({}).sort('-_id').select('_id Result League LeagueSeason MatchCounted RatingDire RatingRadiant MatchType MatchCompleted').exec(function (err, results) {
    if(err) { return handleError(res, err); }
    return res.status(200).json(results);
  });
};

// Get a single result
exports.show = function(req, res) {
  var id = req.params.id;
  Result.findOne({_id: id}, function (err, result) {
    if(err) { console.log(err); return handleError(res, err); }
    if(!profile) { return res.send(404); }
    return res.json(result);
  });
};

function handleError(res, err) {
    return res.send(500, err);
}
