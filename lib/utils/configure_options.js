var fs = require('fs'),
    path = require('path'),
    shell = require('shelljs'),
    adapters = require('../adapters'),
    colors = require('colors');

require('coffee-script');

// configure_options
// -----------------
// Parses the app.coffee file in a roots static project,
// adds and configures any additional options, and puts all
// config options inside `global.config`

module.exports = function(cb){

  if (!fs.existsSync(path.join(process.cwd() + '/app.coffee'))) {

    console.error("\nnot a roots project - run `roots help` if you are confused\n".yellow);

  } else {

    // pull the app config file
    var options = global.options = require(path.join(process.cwd() + '/app.coffee'));

    if (!options.folder_config) {
      options.folder_config = { views: 'views', assets: 'assets' }; 
    }

    // livereload function won't render anything unless in watch mode
    if (!options.locals) { options.locals = {}; }
    options.locals.livereload = "";

    // figure out which files need to be compiled
    var extensions = options.compiled_extensions = [];

    // look in core first
    for (var key in adapters) {
      extensions.push(adapters[key].settings.file_type);
    }

    // then look in plugins
    var plugin_path = path.join(process.cwd() + '/plugins'),
        plugins = fs.existsSync(plugin_path) && shell.ls(plugin_path);

    for (var i = 0; i < plugins.length; i++) {
      if (plugins[i].match(/.+\.(?:js|coffee)$/)) {
        var compiler = require(path.join(plugin_path, plugins[i]));
        if (compiler.settings && compiler.settings.file_type) {
          extensions.push(compiler.settings.file_type);
        }
      }
    }

    // make sure all layout files are ignored
    if (!options.ignore_files) { options.ignore_files = []; }
    if (!options.layouts) { options.layouts = {}; }

    for (var key in options.layouts){
      options.ignore_files.push(options.layouts[key]);
    }

    // add app.coffee to the file ignores
    options.ignore_files.push('app.coffee')

    // add plugins, and public folders to the folder ignores
    if (!options.ignore_folders) { options.ignore_folders = [] };
    options.ignore_folders = options.ignore_folders.concat(['public', 'plugins'])

    // configure the base watcher ignores
    if (!options.watcher_ignore_folders) { options.watcher_ignore_folders = [] };
    if (!options.watcher_ignore_files) { options.watcher_ignore_files = [] };
    
    options.watcher_ignore_folders = options.watcher_ignore_folders.concat(['components', 'public', 'plugins', '.git'])
    options.watcher_ignore_files = options.watcher_ignore_files.concat(['.DS_Store'])

    // format the file/folder ignore patterns
    options.ignore_files = format_ignores(options.ignore_files)
    options.ignore_folders = format_ignores(options.ignore_folders)
    options.watcher_ignore_folders = format_ignores(options.watcher_ignore_folders)
    options.watcher_ignore_files = format_ignores(options.watcher_ignore_files)

    function format_ignores(ary){
      return ary.map(function(pat){ return "!" + pat.toString().replace(/\//g, "") });
    }

    // if debugging is needed, set this to true
    options.debug = {
      status: false,
      log: function(data){ if (this.status) { console.log(data.grey); } }
    };

    // finish it up!
    options.debug.log('config options set');
    cb();

  }
};
