var path = require('path'),
    _ = require('underscore'),
    roots = require('../index');

// takes a path from a roots project and outputs the path
// that it will compile to.

module.exports = function(file){
  var dirs = roots.project.dirs;
  var extensions = path.basename(file).split('.');
  var adapters = require('../adapters');

  // dump views/assets folders to public
  base_folder = file.replace(roots.project.rootDir, '').slice(1).split(path.sep);
  if (base_folder[0] == dirs['views'] || base_folder[0] == dirs['assets']) {
    base_folder.shift();
  }
  base_folder.unshift(dirs['public']);
  result = base_folder.join(path.sep);

  // iterate through extensions (starting with index #1) to find an adapter
  for (var i = 1; i < extensions.length; i++) {
    if ( adapters[extensions[i]] ) {
      result = result.replace(new RegExp('\\.' + extensions[i] + '.*'), '.' + adapters[extensions[i]].settings.target);
      return path.join(roots.project.rootDir, result);
    }
  }

  return path.join(roots.project.rootDir, result);
};
