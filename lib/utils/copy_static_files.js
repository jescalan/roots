require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    compress = require('./compressor'),
    current_directory = path.normalize(process.cwd());

module.exports = function(files, next){

  files.forEach(function(file){
    var source = path.join(current_directory, global.options.folder_config.assets, file);
    var destination = path.join(current_directory, 'public', file);
    var write_content = fs.readFileSync(source, 'utf8');
    var extname = path.extname(file).slice(1);
    var types = ['html', 'css', 'js'];

    if (global.options.compress && types.indexOf(extname) > 0){ write_content = compress(write_content, extname) }

    fs.writeFileSync(destination, write_content);
  });

  next([], false);

}