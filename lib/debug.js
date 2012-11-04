// configuration for compilers. this should make things more dry, eventually
// right now it helps with the debug flag
colors = require('colors');

var debug = false;

exports.status = debug;
exports.set_debug = function(status){ debug = status; }
exports.log = function(data){ if (debug) { console.log(data.grey); } }

// Honestly, this should be moved into global.options. Silly to have
// it in its own file with a setter method. But that is a decent amount
// of work and isn't super high prioirt so I'll do it later.