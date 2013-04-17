var path = require('path'),
    _ = require('underscore'),
    adapters = require('../adapters');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){

  var folder_config = global.options.folder_config;

  var transform1 = path.join(global.options.exportDirectory, file.replace(process.cwd(),''));
  var output_path = _.reject(_.compact(transform1.split(path.sep)), function(i){ return i === folder_config.views || i === folder_config.assets }).join(path.sep)
  var extension = path.extname(file).slice(1);

  if (adapters[extension]) {
    var target_extension = adapters[extension].settings.target;
    output_path = output_path.replace(new RegExp(extension + "$"), target_extension);
  }

  return output_path;
};
