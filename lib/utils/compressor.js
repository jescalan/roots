// Hi, I just minify files and stuff

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {

    var UglifyJS = require("uglify-js");

    var toplevel_ast = UglifyJS.parse(content, {});
    toplevel_ast.figure_out_scope();
    var compressor = UglifyJS.Compressor();
    var compressed_ast = toplevel_ast.transform(compressor);
    compressed_ast.figure_out_scope();
    compressed_ast.compute_char_frequency();
    compressed_ast.mangle_names();
    var stream = UglifyJS.OutputStream();
    compressed_ast.print(stream);
    return stream.toString();

  }

  // https://github.com/GoalSmashers/clean-css
  if (extension === 'css'){
    return require('clean-css').process(content);
  }

  return content;

};
