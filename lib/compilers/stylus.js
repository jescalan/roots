var stylus = require('stylus'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(root, files){
  if (typeof files !== 'undefined') { 
    files.forEach(function(file){

      // wouldn't mind defining a couple custom asset pipeline functions in here
      // it's super easy and would be bad ass as hell
      // https://github.com/LearnBoost/stylus/blob/master/docs/js.md

      var dir = path.dirname(file);
      var basename = path.basename(file, '.styl');
      var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
      var compiled_path = path.join(current_directory, 'public', dir, (basename + '.css'));
      stylus.render(file_contents, function(err, compiled_css){
        fs.writeFileSync(compiled_path, compiled_css); // write the file
      });

    });
  }
}