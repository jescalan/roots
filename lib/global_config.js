
//
// an interface to the roots global configuration file
//

var fs = require('fs'),
    path = require('path');

var home_dir = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
var config_path = exports.path = path.join(home_dir, '.rootsrc');

// based on the data type passed, modifies the config appropriately.
// strings, integers, and functions have their values overridden, arrays
// and objects are appended to.
// ex. modify('package_manager', 'cdnjs')
// ex: modify('templates', { test: 'https://github.com/test/test' })

exports.modify = function(key, val){
  var config = read_or_create();

  // make sure the type of the value being modified matches
  var type = get_type(val);
  if (get_type(config[key]) !== type) { return false }

  // each type needs to be modified differently
  switch (type) {
    case 'array':
      config[key].push(val);
      break;
    case 'object':
      for (k in val){ config[key][k] = val[k] };
      break;
    default: // string, integer, or function
      config[key] = val;
  }

  write(config);
  return config
}

// be careful!

exports.remove = function(base, prop){
  var config = read_or_create();

  if (!prop){
    delete config[base];
  } else {
    delete config[base][prop];
  }

  write(config);
  return config
}

exports.get = read_or_create;

//
// @api private
//

// read the config file and return an object
function read(){
  return JSON.parse(fs.readFileSync(config_path, 'utf8'))
}

// creates a new global config file based on a template
function create(){
  var tmpl_path = path.join(__dirname, '../templates/global_config/default.json');
  var tmpl_contents = fs.readFileSync(tmpl_path, 'utf8');
  fs.writeFileSync(config_path, tmpl_contents);
  return read()
}

// reads/creates and returns the global config as an object
function read_or_create(){
  if (fs.existsSync(config_path)) { return read() } else { return create() }
}

// write a javascript object to the config file as yaml
function write(content){
  var to_json = JSON.stringify(content, null, "  ");
  fs.writeFileSync(config_path, to_json);
  return content
}

// because javascript's type checking is terrible
function get_type(x){
  if (typeof x !== 'object'){
    return typeof x;
  } else {
    if (Array.isArray(x)) { return 'array' } else { return 'object' }
  }
}
