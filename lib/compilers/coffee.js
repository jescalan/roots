var coffee = require('coffee-script');
var path = require('path');
var fs = require('fs');
var helpers = require('../helpers');
var current_directory = path.normalize(process.cwd());

exports.compile = function(files){
  files.forEach(function(file, index){

    // get all the info we need for the paths
    var dir = path.normalize(path.dirname(file));
    var basename = path.normalize(path.basename(file, '.coffee'));
    var file_contents = fs.readFileSync(path.join(current_directory, '/assets/js', file), 'utf8');
    var compiled_path = path.join(current_directory, 'public/js', dir, (basename + '.js'));
    var compiled_js = coffee.compile(file_contents);

    // create directories if needed
    helpers.mkdirp(path.join(current_directory, 'public/js', dir), '0777', function(){
      fs.writeFileSync(compiled_path, compiled_js); // then write the file
    });

  });
}