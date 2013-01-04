var fs = require('fs'),
    path = require('path'),
    shell = require('shelljs'),
    adapters = require('../adapters'),
    colors = require('colors');

require('coffee-script');

module.exports = function(cb){

  if (!fs.existsSync(path.join(process.cwd() + '/app.coffee'))) {

    console.error("\nnot a roots project - run `roots help` if you are confused\n".yellow);

  } else {

    // pull the app config file
    var options = global.options = require(path.join(process.cwd() + '/app.coffee'));

    // convention over configuration
    options.folder_config = {
      views: 'views',
      assets: 'assets'
    };

    // make sure all layout files are ignored
    for (var key in options.layouts){
      options.ignore_files.push(new RegExp(options.layouts[key]));
    }

    // livereload function won't render anything unless in watch mode
    options.locals.livereload = "";

    // i'm honestly the only one that uses this, removed from app config default.
    options.debug = {
      status: false,
      log: function(data){ if (this.status) { console.log(data.grey); } }
    }

    // figure out which files need to be compiled
    var extensions = options.compiled_extensions = [];

    // look in core first
    for (var i = 0; i < adapters.length; i++) {
      extensions.push(compiler.settings.file_type);
    }

    // then look in plugins
    var plugin_path = path.join(process.cwd() + '/plugins'),
        plugins = fs.existsSync(plugin_path) && shell.ls(plugin_path);

    for (var i = 0; i < plugins.length; i++) {
      if (plugins[i].match(/.*\.[js|coffee]+$/)) {
        var compiler = require(path.join(plugin_path, plugins[i]));
        if (compiler.settings && compiler.settings.file_type) {
          extensions.push(compiler.settings.file_type);
        }
      }
    }

    cb();

  }
}