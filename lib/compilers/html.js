var static_compile = require('./static').copy_files;

exports.compile = function(files, cb){
  static_compile('html', files, cb);
}