var path = require('path'),
    colors = require('colors'),
    _ = require('underscore'),
    async = require('async'),
    readdirp = require('readdirp'),
    FTPClient = require('ftp'),
    roots = require('../index'),
    shell = require('shelljs');

var ftp = module.exports = {},
    client = new FTPClient();

ftp.check_credentials = function(cb){

  console.log('')
  console.log("WARNING - this module is not complete. use at your own risk".red)
  console.log("hit control + c quickly to cancel if this was a mistake".red)
  console.log('')

  console.log('checking credentials...'.grey);
  var credentials = global.options.ftp;

  client.connect({
    host: credentials.host,
    port: typeof credentials.port == "undefined" ? '21' : credentials.port,
    user: credentials.username,
    password: credentials.password
  });

  client.on('ready', function(){
    console.log('authenticated!'.grey);
    client.cwd(credentials.root, function(err){
      if (err) { return console.error(err); }
      cb();
    });
  });

  client.on('error', function(err){
    console.log('connection error'.red);
    console.log(err);
  });
  
};

ftp.push_code = function(cb){
  console.log('pushing project via ftp (this may take a few seconds)...'.grey);
  console.log('');

  clear_files('.', function(){
    
    readdirp({ root: path.join(roots.project.root_dir, options.output_folder) }, function(err, res){
      if (err) { return console.error(err); }

      var folders = _.pluck(res.directories, 'path');
      var files = _.pluck(res.files, 'path');

      async.map(folders, mkdir, function(err){
        if (err){ return console.error(err); }
        async.map(files, put_file, function(err){
          if (err){ return console.error(err); }
          client.end();
          console.log('');
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
    console.log('uploading '.green + file);
    client.put(path.join(roots.project.root_dir, options.output_folder, file), file, cb);
  }
  
  function clear_files(dir, cb){

    client.list(dir, function(err, list){
      if (err) { return console.error(err); }

      async.map(list, function(entry, callback){
        if (entry.name == '.' || entry.name == '..'){ return callback() }
        if (entry.type === 'd') {
          clear_files(entry.name, function(){
            if (entry.name !== '.'){
              client.rmdir(entry.name, callback);
            } else {
              callback();
            }
          });
        } else {
          console.log('removing '.red + dir + '/' + entry.name);
          client.delete(dir + '/' + entry.name, callback);
        }
      }, function(){ cb(); } );

    });
  }

};
