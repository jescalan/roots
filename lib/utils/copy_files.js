var path = require('path'),
    get_compiler = require('./get_compiler'),
    copySync = require('./copy_sync'),
    current_directory = path.normalize(process.cwd());

module.exports = function(files, next){

  files.forEach(function(file){
    var source = path.join(current_directory, global.options.folder_config.assets, file);
    var destination = path.join(current_directory, 'public', file);
    copySync(source, destination);
  });

  next([], false);

}