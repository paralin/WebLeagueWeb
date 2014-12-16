'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var VouchSchema = new Schema({
    _id: String,
    name: String,
    avatar: String,
    teamname: String,
    teamavatar: String
});

module.exports = mongoose.model('vouch', VouchSchema);
