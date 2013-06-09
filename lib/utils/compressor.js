// Hi, I just minify files and stuff

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {

    var uglify = require("uglify-js");
    var jsp = uglify.parser;
    var pro = uglify.uglify;

    var ast = jsp.parse(content);
    ast = pro.ast_mangle(ast);
    ast = pro.ast_squeeze(ast);
    return pro.gen_code(ast);
  }

  // https://github.com/GoalSmashers/clean-css
  if (extension === 'css'){
    return require('clean-css').process(content);
  }

  return content;

};
