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

  // pull the app config file
  var config_path = path.join(process.cwd() + '/app.coffee');
  var options = global.options = fs.existsSync(config_path) ? require(config_path) : {};

  if (!options.folder_config) {
    options.folder_config = { views: 'views', assets: 'assets' }; 
  }

  // livereload function won't render anything unless in watch mode
  if (!options.locals) { options.locals = {}; }
  options.locals.livereload = "";

  // figure out which files need to be compiled
  var extensions = options.compiled_extensions = [];

  for (var key in adapters) {
    extensions.push(adapters[key].settings.file_type);
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

  // this is currently not working because of an issue with
  // readdirp: https://github.com/thlorenz/readdirp/issues/4
  if (options.templates){ options.ignore_folders = options.ignore_folders.concat([options.templates]) }

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

};
