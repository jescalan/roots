
//
// an interface to the roots global configuration file
//

var fs = require('fs'),
    path = require('path'),
    yaml = require('js-yaml');

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

  // each of these types need to be modified differently
  if (type === 'string' || type === 'integer' || type === 'function') {
    config[key] = val; // value: set value
  } else if (type === 'array') {
    config[key].push(val); // array: add to array
  } else if (type === 'object') {
    for (k in val){ config[key][k] = val[k] } // object: add/set object(s)
  } else {
    console.log('error: type not recognized');
    return false;
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
  return yaml.safeLoad(fs.readFileSync(config_path, 'utf8'))
}

// creates a new global config file based on a template
function create(){
  var tmpl_path = path.join(__dirname, '../templates/global_config/default.yml');
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
  var to_yaml = yaml.safeDump(content);
  fs.writeFileSync(config_path, to_yaml);
  return content
}

// because javascript's type checking is terrible
function get_type(x){
  if (typeof x !== 'object'){
    return typeof x;
  } else {
    if (x instanceof Array) { return 'array' } else { return 'object' }
  }
}