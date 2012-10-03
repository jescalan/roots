var static_compile = require('./static').copy_files;

exports.compile = function(root, files, layout, cb){
  static_compile(root, files, cb);
}