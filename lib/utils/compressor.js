var transformer = require('transformers'),
autoprefixer = require('autoprefixer');

// TODO: This should ignore js files with ".min" in the name
module.exports = function(content, extension){
  if (extension === 'js') return transformer['uglify-js'].renderSync(content);
  if (extension === 'css') {
    prefix_adjusted = autoprefixer.compile(css);
    return transformer['uglify-css'].renderSync(prefix_adjusted);
  }
  return content;
};
