var path = require('path'),
    adapters = require('../adapters');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){
  var output_path = path.join(process.cwd(), 'public', file.replace(process.cwd(),'').replace(/^\/assets|\/views/,''));
  var extension = path.extname(file).slice(1)

  if (adapters[extension]) {
    var target_extension = adapters[extension].settings.target
    output_path = output_path.replace(new RegExp(extension + "$"), target_extension);
  }

  return output_path;
}