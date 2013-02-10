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

  // https://github.com/css/csso
  if (extension === 'css'){
    return require('csso').justDoIt(content);
  }

  // https://github.com/kangax/html-minifier
  // i've had the most issues with this particular one, be careful...
  if (extension === 'html'){
    opts = {
      removeComments: true,
      collapseBooleanAttributes: true,
      removeCDATASectionsFromCDATA: true,
      removeEmptyAttributes: true
    };
    return require('html-minifier').minify(content, opts);
  }

};
