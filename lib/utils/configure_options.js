var fs = require('fs'),
    path = require('path'),
    shell = require('shelljs'),
    adapters = require('../adapters'),
    colors = require('colors');

require('coffee-script');

// config parser
// -----------------
// Parses the app.coffee file in a roots project,
// adds and configures any additional options, and puts all
// config options inside `global.options`

module.exports = function(cb){

  // pull the app config file
  var config_path = path.join(process.cwd() + '/app.coffee');
  var opts = global.options = fs.existsSync(config_path) ? require(config_path) : {};

  // set views and assets folders
  if (!opts.folder_config) {
    opts.folder_config = { views: 'views', assets: 'assets' }; 
  }

  // set up public folder
  if (!opts.output_folder) {
    opts.output_folder = 'public';
  }

  // livereload function won't render anything unless in watch mode
  if (!opts.locals) { opts.locals = {}; }
  opts.locals.livereload = "";

  // figure out which files need to be compiled
  var extensions = opts.compiled_extensions = [];

  for (var key in adapters) {
    extensions.push(adapters[key].settings.file_type);
  }

  // make sure all layout files are ignored
  if (!opts.ignore_files) { opts.ignore_files = []; }
  if (!opts.layouts) { opts.layouts = {}; }

  for (var key in opts.layouts){
    opts.ignore_files.push(opts.layouts[key]);
  }

  // add app.coffee to the file ignores
  opts.ignore_files.push('app.coffee')

  // add plugins, and public folders to the folder ignores
  if (!opts.ignore_folders) { opts.ignore_folders = [] };
  opts.ignore_folders = opts.ignore_folders.concat([opts.output_folder, 'plugins'])

  // ignore js templates folder
  // this is currently not working because of an issue with
  // readdirp: https://github.com/thlorenz/readdirp/issues/4
  if (opts.templates){ opts.ignore_folders = opts.ignore_folders.concat([opts.templates]) }

  // configure the base watcher ignores
  if (!opts.watcher_ignore_folders) { opts.watcher_ignore_folders = [] };
  if (!opts.watcher_ignore_files) { opts.watcher_ignore_files = [] };

  opts.watcher_ignore_folders = opts.watcher_ignore_folders.concat(['components', 'plugins', '.git', opts.output_folder]);
  opts.watcher_ignore_files = opts.watcher_ignore_files.concat(['.DS_Store']);

  // format the file/folder ignore patterns
  opts.ignore_files = format_ignores(opts.ignore_files);
  opts.ignore_folders = format_ignores(opts.ignore_folders);
  opts.watcher_ignore_folders = format_ignores(opts.watcher_ignore_folders);
  opts.watcher_ignore_files = format_ignores(opts.watcher_ignore_files);

  function format_ignores(ary){
    return ary.map(function(pat){ return "!" + pat.toString().replace(/\//g, "") });
  }

  // if debugging is needed, set this to true
  if (!opts.debug) {
    opts.debug = { status: false };
  } else {
    var temp = opts.debug;
    opts.debug = { status: temp };
  }

  opts.debug.log = function(data, color){
    if (!color) { color = 'grey' }
    this.status && console.log(data[color]);
  }

  // finish it up!
  opts.debug.log('config options set');
  cb();

};
