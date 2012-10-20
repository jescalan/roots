var static_compile = require('./static').copy_files;

exports.compile = function(files, cb){
  static_compile('css', files, cb);
}