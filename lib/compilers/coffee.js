var coffee = require('coffee-script');
var path = require('path');
var fs = require('fs');
var helpers = require('../helpers');
var current_directory = path.normalize(process.cwd());

exports.compile = function(directory){
  helpers.find_files(directory, 'coffee', function(file){

    var dir = path.dirname(file.path);
    var basename = path.basename(file.path, '.coffee');
    var file_contents = fs.readFileSync(path.join(current_directory, 'assets', file.path), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.js'));
    var compiled_js = coffee.compile(file_contents);

    fs.writeFileSync(compiled_path, compiled_js); // write the file

  });
}