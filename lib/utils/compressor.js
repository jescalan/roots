transformer = require('transformers');

module.exports = function(content, extension){
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') return transformer['uglify-js'].renderSync(content);
  if (extension === 'css') return transformer['uglify-css'].renderSync(content);
  return content;
};
