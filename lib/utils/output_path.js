var path = require('path'),
    _ = require('underscore'),
    adapters = require('../adapters');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){

  var fc = global.options.folder_config;
  var extension = file.split('.')[1]; // this should take the *first* extension only

  // dump views/assets to public
  var result = path.join(file.replace(process.cwd(), 'public'))
                        .replace(new RegExp(fc.views + '|' + fc.assets), '');

  // swap extension if needed
  if (adapters[extension]) {
    result = result.replace(new RegExp('\\.' + extension + '.*'), '.' + adapters[extension].settings.target);
  }

  return path.join(process.cwd(), result);
};
