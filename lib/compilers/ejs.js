var ejs = require('ejs'),
    path = require('path'),
    fs = require('fs'),
    debug = require('../debug'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(root, files, layout, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    // need to deal with layout functionality
    // as well as partials and optional variables

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.html'));
    var compiled_ejs = ejs.compile(file_contents, { filename: path.join(current_directory, root, file) });

    fs.writeFileSync(compiled_path, compiled_ejs());

    debug.log('compiled ' + path.basename(file));
  });
  cb();
}