// configuration for compilers. this should make things more dry, eventually
// right now it helps with the debug flag
colors = require('colors');

var debug = true;

exports.log = function(data){
  if (debug) { console.log(data.grey); }
}