
exports.copy_files = function(files, Helper, cb){
  files !== undefined && files.forEach(function(file){

    var helper = new Helper(file)
    helper.write(helper.file_contents)

  });
  cb();
}