var path = require('path'),
    colors = require('colors'),
    _ = require('underscore'),
    async = require('async'),
    readdirp = require('readdirp'),
    FTPClient = require('ftp'),
    shell = require('shelljs'),
    roots = require('../index');

var ftp = module.exports = {},
    client = new FTPClient();

ftp.check_credentials = function(cb){

  roots.print.log('');
  roots.print.log("WARNING - this module is not complete. use at your own risk", 'red');
  roots.print.log("hit control + c quickly to cancel if this was a mistake", 'red');
  roots.print.log('');

  roots.print.log('checking credentials...', 'grey');
  var credentials = global.options.ftp;

  client.connect({
    host: credentials.host,
    port: typeof credentials.port == "undefined" ? '21' : credentials.port,
    user: credentials.username,
    password: credentials.password
  });

  client.on('ready', function(){
    roots.print.log('authenticated!', 'grey');
    client.cwd(credentials.root, function(err){
      if (err) return roots.print.error(err);
      cb();
    });
  });

  client.on('error', function(err){
    roots.print.log('connection error', 'red');
    roots.print.log(err);
  });
  
};

ftp.push_code = function(cb){
  roots.print.log('pushing project via ftp (this may take a few seconds)...', 'grey');
  roots.print.log('');

  clear_files('.', function(){
    
    readdirp({ root: path.join(process.cwd(), options.output_folder) }, function(err, res){
      if (err) return roots.print.error(err);

      var folders = _.pluck(res.directories, 'path');
      var files = _.pluck(res.files, 'path');

      async.map(folders, mkdir, function(err){
        if (err) return roots.print.error(err);
        async.map(files, put_file, function(err){
          if (err) return roots.print.error(err);
          client.end();
          roots.print.log('');
          cb();
        });
      });

    });

  });
  
  //
  // private
  //
  
  function mkdir(dir, cb){
    client.mkdir(dir, true, cb);
  }

  function put_file(file, cb){
    roots.print.log('uploading '.green + file);
    client.put(path.join(process.cwd(), options.output_folder, file), file, cb);
  }
  
  function clear_files(dir, cb){

    client.list(dir, function(err, list){
      if (err) { return roots.print.error(err); }

      async.map(list, function(entry, callback){
        if (entry.name == '.' || entry.name == '..') return callback();
        if (entry.type === 'd') {
          clear_files(entry.name, function(){
            if (entry.name !== '.'){
              client.rmdir(entry.name, callback);
            } else {
              callback();
            }
          });
        } else {
          roots.print.log('removing '.red + dir + '/' + entry.name);
          client.delete(dir + '/' + entry.name, callback);
        }
      }, function(){ cb(); } );

    });
  }

};
