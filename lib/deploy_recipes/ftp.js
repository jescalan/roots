var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    _ = require('underscore'),
    async = require('async'),
    readdirp = require('readdirp'),
    FTPClient = require('ftp'),
    shell = require('shelljs');

var ftp = module.exports = {};
var client = new FTPClient();

ftp.check_credentials = function(cb){
  console.log('checking credentials...'.grey);
  var credentials = global.options.ftp;

  client.connect({
    host: credentials.host,
    port: credentials.port === undefined ? '21' : credentials.port,
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

  readdirp({ root: path.join(process.cwd(), 'public') }, function(err, res){
    if (err) { return console.error(err); }

    var folders = _.pluck(res.directories, 'path');
    var files = _.pluck(res.files, 'path');

    async.map(folders, mkdir, function(err){
      if (err){ return console.error(err); }
      async.map(files, put_file, function(err){
        if (err){ return console.error(err); }
        console.log('done transferring files');
        client.end();
        cb();
      });
    });

    function mkdir(dir, cb){ console.log(dir); client.mkdir(dir, true, cb); }
    function put_file(file, cb){ console.log(file); client.put(file, file, function(err){
      console.log('worked?');
    }); }
  });

};
