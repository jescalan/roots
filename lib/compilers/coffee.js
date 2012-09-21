var Snockets = require('snockets'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());


exports.compile = function(root, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    // this uses snockets to compile, which makes the require command
    // available within coffeescript files. dope!
    
    // the only other thing I'd like to add here is ignoring files that start with an _

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.js'));

    // console.log(current_directory, root, file);

    var snockets = new Snockets();
    var compiled_js = snockets.getConcatenation(path.join(current_directory, root, file), { async: false });

    fs.writeFileSync(compiled_path, compiled_js); // write the file

    console.log('compiled ' + path.basename(file));
    cb();

  });
}