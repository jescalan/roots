// Hi, I just minify files and stuff

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS2
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {
    UglifyJS = require('uglify-js');
    toplevel_ast = UglifyJS.parse(content);
    toplevel_ast.figure_out_scope();
    compressed_ast = toplevel_ast.transform(UglifyJS.Compressor());
    compressed_ast.figure_out_scope();
    compressed_ast.compute_char_frequency();
    compressed_ast.mangle_names();
    return compressed_ast.print_to_string();
  }

  // https://github.com/GoalSmashers/clean-css
  if (extension === 'css'){
    return require('clean-css').process(content);
  }

  // https://github.com/kangax/html-minifier
  // too many issues with this minifier, looking at other options
  if (extension === 'html'){
    return content
  }

};
