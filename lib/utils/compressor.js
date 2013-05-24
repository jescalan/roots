// Hi, I just minify files and stuff

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {

    var jsp = require("uglify-js").parser;
    var pro = require("uglify-js").uglify;

    var ast = jsp.parse(content);
    ast = pro.ast_mangle(ast);
    ast = pro.ast_squeeze(ast);
    return pro.gen_code(ast);
  }

  // https://github.com/GoalSmashers/clean-css
  if (extension === 'css'){
    return require('clean-css').process(content);
  }

  // https://github.com/kangax/html-minifier
  // removed this minifier, using jade instead
  if (extension === 'html'){
    return content
  }

};
