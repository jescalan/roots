// Hi, I just minify files and stuff

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS2
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
  if (extension === 'html'){
    opts = {
        removeComments: true
      , collapseBooleanAttributes: true
      , removeCDATASectionsFromCDATA: true
      , removeAttributeQuotes: true
      , removeEmptyAttributes: true
    };
    return require('html-minifier').minify(content, opts);
  }

}