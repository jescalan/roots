var Snockets = require('snockets'),
    path = require('path'),
    fs = require('fs'),
    debug = require('../debug'),
    current_directory = path.normalize(process.cwd());

exports.compile = function(root, files, layouts, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    // this uses snockets to compile, which makes the require command
    // available within coffeescript files. dope!

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.js'));
    var snockets = new Snockets();
    var compiled_js = snockets.getConcatenation(path.join(current_directory, root, file), { async: false });

    fs.writeFileSync(compiled_path, compiled_js); // write the file

    debug.log('compiled ' + path.basename(file));
    

  });

  cb(); // hit callback when done with compiling all files of this type
}