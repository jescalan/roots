require('coffee-script');
roots = require('../index');

var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs');

// load in all the core adapters
module.exports = {
  jade: require('./jade'),
  ejs: require('./ejs'),
  coffee: require('./coffee'),
  scss: require('./scss'),
  styl: require('./styl'),
  eco: require('./eco'),
  mustache: require('./mustache'),
  hamlc: require('./hamlc'),
  less: require('./less'),
  md: require('./markdown')
};

// load any extra plugins
var plugin_path = roots.project.path('plugins'),
    plugins = fs.existsSync(plugin_path) && shell.ls(plugin_path);

plugins && plugins.forEach(function(plugin){
  if (plugin.match(/.+\.(?:js|coffee)$/)) {
    var compiler = require(path.join(plugin_path, plugin));
    var name = path.basename(compiler.settings.file_type);
    if (compiler.settings && compiler.compile) {
      module.exports[name] = compiler;
    }
  }
});
