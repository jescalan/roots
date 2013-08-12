var path = require('path'),
    _ = require('underscore'),
    adapters = require('../adapters'),
    roots = require('../index');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){

  var dirs = roots.project.dirs;
  var extension = path.basename(file).split('.')[1]; // this should take the *first* extension only

  // dump views/assets folders to public
  base_folder = file.replace(roots.project.rootDir, '').slice(1).split(path.sep)
  if (base_folder[0] == dirs.views.slice(2) || base_folder[0] == dirs.assets.slice(2)) {
    base_folder.shift()
  }
  base_folder.unshift(dirs['public']);
  result = base_folder.join(path.sep);

  // swap extension if needed
  if (adapters[extension]) {
    result = result.replace(new RegExp('\\.' + extension + '.*'), '.' + adapters[extension].settings.target);
  }

  return path.join(roots.project.rootDir, result);
};
