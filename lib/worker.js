require('coffee-script/register');

var path       = require('path'),
    _ = require('lodash'),
    Config     = _req('config'),
    Compiler = _req('compiler'),
    Extensions = _req('extensions'),
    EventEmitter = require('events').EventEmitter,
    File = require('vinyl');

//
// setup
//

var roots = new EventEmitter,
    self = this,
    exts = null,
    compiler = null;

roots.root = process.argv.slice(2)[0];
roots.bail = _req('api/bail');
roots.config = new Config(roots, process.argv.slice(2)[1]);

var extensions = new Extensions(roots)

//
// message delegation
//

process.on('message', function(args){
  compile.apply(null, args);
});

//
// methods
//

function compile(id, category, file){
  file = new File(file)
  if (!exts) exts = extensions.instantiate();
  if (!compiler) compiler = new Compiler(roots, exts);

  compiler.compile(category, file).done(function(){
    process.send({ id: id, data: true });
  }, function(err){
    console.log(err.stack)
    process.send({ id: id, data: err });
  });
}

//
// utils
//

function _req(mod){
  return require(path.join(__dirname, mod));
}
