var path = require('path'),
    deferred = require('q').defer(),
    readdirp = require('readdirp');

// analyze project
// ---------------
// Reads through the roots project and returns an object containing
// the following arrays:
// 
//   - folders: directories that need to be created
//   - compiled_files: files that need to be compiled
//   - static_files: files that can simply be copied

module.exports = function(){

  // D-BUG
  console.log('analyzing project');

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