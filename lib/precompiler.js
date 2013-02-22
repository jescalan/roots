var path = require('path'),
    fs = require('fs'),
    Q = require('q'),
    deferred = require('q').defer(),
    _ = require('underscore'),
    tmpl_precompile = require('tmpl-precompile');

// @api private
// precompiles jade templates to javascript functions
// then writes them to a file.

module.exports = function(){

  var root = path.join(global.options.templates, '/');
  var output_path = path.normalize('public/js/templates.js');
  fs.writeFileSync(output_path, '')

  var files = _.map(fs.readdirSync(path.join(process.cwd(), root)), function(f){ return path.basename(f, '.jade'); });

  if (typeof global.options.templates === 'undefined') { return false };

  var settings = {
    "relative": false,
    "groups": [{
      "uglify": true,
      "inline": false,
      "debug": false,
      "namespace": "templates",
      "window": false,
      "source": root,
      "output": output_path,
      "templates": files
    }]
  };

  tmpl_precompile.precompile(settings, process.cwd(), deferred.resolve);
  
  return deferred.promise;

}