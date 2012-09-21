var ejs = require('ejs'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(root, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    // need to deal with layout functionality
    // as well as partials and optional variables

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.html'));
    var compiled_ejs = ejs.render(file_contents);

    fs.writeFileSync(compiled_path, compiled_ejs);

    console.log('compiled ' + path.basename(file));
    cb();

  });
}