var transformer = require('transformers'),
    htmlmin = require('html-minifier'),
    cleancss = require('clean-css'),
    autoprefixer = require('autoprefixer');

module.exports = function(content, extension){

  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {
    transformer['uglify-js'].renderSync(content); 
  }

  if (extension === 'css') {
    // prefix_adjusted = autoprefixer.compile(content);
    return cleancss.process(content);
  }

  if (extension === 'html') {
    htmlmin.minify(content, { removeComments: true, collapseWhitespace: true })
  } 

  return content;
};
