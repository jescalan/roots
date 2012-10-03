var jade = require('jade'),
    path = require('path'),
    fs = require('fs'),
    debug = require('../debug'),
    current_directory = path.normalize(process.cwd());

// these should be refactored to have a parent class which would abbreviate
// the shared functionality (with paths specifically)

exports.compile = function(root, files, layout, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    var dir = path.dirname(file);
    var basename = path.basename(file, path.extname(file));
    var file_contents = fs.readFileSync(path.join(current_directory, root, file), 'utf8');
    // there should be a check here to see if the current file matches a layout
    // override instead of using default for everything
    var layout_contents = fs.readFileSync(path.join(current_directory, root, layout.default), 'utf8');
    var compiled_path = path.join(current_directory, 'public', dir, (basename + '.html'));

    var compiled_page = jade.compile(file_contents, { pretty: true, filename: path.join(current_directory, root, file) });
    var compiled_template = jade.compile(layout_contents, { pretty: true })

    fs.writeFileSync(compiled_path, compiled_template({ yield: compiled_page() }));

    debug.log('compiled ' + path.basename(file));
  });
  cb();
}