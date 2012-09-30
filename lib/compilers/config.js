// configuration for compilers. this should make things more dry, eventually
// right now it helps with the debug flag

var debug = false;

exports.debug = function(data){
  if (debug) { console.log(data); }
}