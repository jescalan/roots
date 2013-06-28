var path = require('path');
var _ = require('underscore');
var adapters = require('../adapters');
var roots = require('../index');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){
  var fc = global.options.folder_config;
  var extension = path.basename(file).split('.')[1]; // this should take the *first* extension only

  // dump views/assets to public
  // I'm worried about the second replace call...
  var result = path.join(
    file.replace(roots.project.root_dir, options.output_folder)
  ).replace(
    new RegExp(fc.views + '|' + fc.assets),
    ''
  );

  // swap extension if needed
  if (adapters[extension]) {
    result = result.replace(
      new RegExp('\\.' + extension + '.*'),
      '.' + adapters[extension].settings.target
    );
  }

  return path.join(roots.project.root_dir, result);
};
