var path = require('path'),
    fs = require('fs'),
    readdirp = require('readdirp'),
    Q = require('q'),
    deferred = Q.defer();

// @api private
// precompiles jade templates to javascript functions
// then writes them to a file.

exports.precompile_templates = function(){
  var root = path.join(process.cwd(), global.options.templates);
  var output_path = path.join(process.cwd(), 'public/js/templates.js');

  if (typeof global.options.templates === 'undefined') { return false };

  // first figure out if this is a file or folder
  if (fs.statSync(root).isDirectory()) {
    return precompile_directory(root);
  } else {
    write_templates_file(root, precompile_file(root));
    return Q.fcall(function(){ return true });
  };

  function precompile_directory(path){
    readdirp(path, function(err){
      if (err) { return console.error(err); }
      res.files.forEach(function(file){
        write_templates_file(file, precompile_file(file.fullPath));
      });
      deferred.resolve();
    });
    return deferred.promise;
  };

  function precompile_file(path){
    return jade.compile(fs.readFileSync(path, 'utf8')).toString()
  };

  function write_templates_file(name, content){
    fs.writeFileSync(output_path, "template." + path.basename(file) + " = " + content + "\n");
  };
}