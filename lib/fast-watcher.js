
// Really, when files are monitored, they should be compiled, added, and
// removed on an as-needed basis. Currently, the entire project is re-compiled
// when any file is modified, which is no ideal. This is a framework for making
// as-needed changes.
// 
// This has been tested and picks up changes correctly, although all the logic
// for dealing with the changes still needs to be implemented.

var assets_or_views = function(f, stat){
  var regex = new RegExp(current_directory.replace(/\//g, "\\\/") + '\/(views|assets).*');
  if (f.match(regex)){
    return false;
  } else {
    return true;
  }
}

watch.watchTree(current_directory, { filter: assets_or_views }, function(f, curr, prev){
  if (typeof f == "object" && prev === null && curr === null) {
    // console.log('initial analysis complete');
  } else if (prev === null && !assets_or_views(f)) {
    add_file(f);
  } else if (curr.nlink === 0) {
    remove_file(f);
  } else {
    recompile(f);
  }
});

var add_file = function(file){
  process.stdout.write('adding file: '.green);
  process.stdout.write(path.basename(file).grey + '\n');
  // detect if file or directory
  // if directory, create it
  // if file, check it it needs to be compiled
  // if so run recompile, if not, pass through
}

var remove_file = function(file){
  process.stdout.write('removing file: '.red);
  process.stdout.write(path.basename(file).grey + '\n');
  // detect if file or directory
  // rimraf directories, remove files
}

var recompile = function(file){
  process.stdout.write('compiling: '.yellow);
  process.stdout.write(path.basename(file).grey + '\n');
  // detect file type and compile by that type
}