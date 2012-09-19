var coffee = require('coffee-script'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());


exports.compile = function(root, files){
  typeof files !== 'undefined' && files.forEach(function(file){

    // I would like imports to be available in coffee files, but this tools didn't
    // work to well for me: https://github.com/devongovett/import

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.js'));
    var compiled_js = coffee.compile(file_contents);

    fs.writeFileSync(compiled_path, compiled_js); // write the file

  });
}