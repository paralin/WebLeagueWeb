'use strict';

var _ = require('lodash');
var ActiveMatch = require('./activematch.model');

// Get list of results
exports.index = function(req, res) {
  ActiveMatch.find({}).exec(function (err, results) {
    if(err) { return handleError(res, err); }
    var matches = [];
    results.forEach(function(result){
      var match = result.toObject();
      delete match.Details["Bot"];
      matches.push(match);
    });
    return res.status(200).json(matches);
  });
};

function handleError(res, err) {
    return res.send(500, err);
}
