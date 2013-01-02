var path = require('path'),
    deferred = require('q').defer(),
    readdirp = require('readdirp');

module.exports = function(){

  var project = {}

  // format negate pattern
  var ignores = []
  global.options.ignore_files.forEach(function(pattern){
    ignores.push("!" + pattern.toString().replace(/\//g, ""))
  });

  // read through the current project and organize the files
  readdirp({ root: process.cwd(), directoryFilter: ignores, fileFilter: ignores }, function(err, res){

    if (err) { console.error(err) }

    project = {
      folders: res.directories,
      compiled_files: [],
      static_files: []
    }

    res.files.forEach(function(file){
      // TODO: Make sure compiled extensions is in the global config
      if (global.options.compiled_extensions.indexOf(path.extname(file)) > 0) {
        project.compiled_files.push(file);
      } else {
        project.static_files.push(file);
      }
    });

    deferred.resolve(project);

  });

  return deferred.promise;

}