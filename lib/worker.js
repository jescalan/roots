require('coffee-script/register');

var path       = require('path'),
    _ = require('lodash'),
    Config     = _req('config'),
    Compiler = _req('compiler'),
    Extensions = _req('extensions'),
    EventEmitter = require('eventemitter2').EventEmitter2,
    File = require('vinyl');

//
// setup
//

var roots = new EventEmitter,
    self = this,
    exts = null,
    compiler = null;

var extensions = new Extensions(roots);

roots.root = process.argv.slice(2)[0];
roots.bail = _req('api/bail');
roots.extensions = extensions;
roots.config = new Config(roots, JSON.parse(process.argv.slice(2)[1]));

//
// message delegation
//

roots.onAny(function(data){
  process.send({ eventName: this.event, data: data })
});

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
  var start = new Date;

  compiler.compile(category, file).done(function(){
    // TODO: refactor this into promise/notify through cli events
    if (roots.config.verbose) {
      console.log(('▸ '+file.relative+': '+(new Date - start)+'ms').grey);
    }
    process.send({ id: id, data: true });
  }, function(err){
    process.send({ id: id, data: err });
  });
}

//
// utils
//

function _req(mod){
  return require(path.join(__dirname, mod));
}
