// configuration for compilers. this should make things more dry, eventually
// right now it helps with the debug flag

var debug = true;

exports.debug = function(data){
  if (debug) { console.log(data); }
}