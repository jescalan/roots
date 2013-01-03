// This file is going to be deleted and debug will be moved to global config

var colors = require('colors');
var debug = false;

exports.status = debug;
exports.set_debug = function(status){ debug = status; }
exports.log = function(data){ if (debug) { console.log(data.grey); } }