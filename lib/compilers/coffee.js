var coffee = require('coffee-script'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(files){
  files.forEach(function(file){

    var dir = path.dirname(file);
    var basename = path.basename(file, '.coffee');
    var file_contents = fs.readFileSync(path.join(current_directory, 'assets', file), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.js'));
    var compiled_js = coffee.compile(file_contents);

    fs.writeFileSync(compiled_path, compiled_js); // write the file

  });
}