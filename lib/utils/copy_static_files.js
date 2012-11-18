require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    copySync = require('./copy_sync'),
    compress = require('./compressor'),
    current_directory = path.normalize(process.cwd());

module.exports = function(target_folder, files, next){

  files.forEach(function(file){
    var source = path.join(current_directory, target_folder, file);
    var destination = path.join(current_directory, 'public', file);
    var extname = path.extname(file).slice(1);
    var types = ['html', 'css', 'js'];

    if (types.indexOf(extname) > 0) {
      var write_content = fs.readFileSync(source, 'utf8');
      if (global.options.compress) { write_content = compress(write_content, extname); }
      fs.writeFileSync(destination, write_content);
    } else {
      copySync(source, destination);
    }

  });

  next([], false);

}