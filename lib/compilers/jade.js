var jade = require('jade'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(root, files){
  if (typeof files !== 'undefined') { 
    files.forEach(function(file){

      // need to deal with layout functionality
      // as well as partials and optional variables

      var dir = path.dirname(file);
      var basename = path.basename(file, '.jade');
      var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
      var compiled_path = path.join(current_directory, 'public', dir, (basename + '.html'));
      var compiled_jade = jade.compile(file_contents, { pretty: true });

      fs.writeFileSync(compiled_path, compiled_jade());

    });
  }
}