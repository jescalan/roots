var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    _ = require('underscore'),
    shell = require('shelljs');
    async = require('async'),
    readdirp = require('readdirp');
    AWS = require('aws-sdk');
    mime = require('mime');

var s3 = module.exports = {};

s3.check_credentials = function(cb){
  var config_file_path = './s3.json'

  fs.exists(config_file_path, function(exists) {
    if (exists) {
      var config        = JSON.parse(AWS.util.readFileSync(config_file_path));
      AWS.config        = new AWS.Config(config);
      AWS.config.bucket = config.bucket
    } else {
      return console.error("no S3 config file present. please create s3.json in the current directory with the proper configuration:\n\n{\n  'accessKeyId': 'XXXXXXXXXXXXXXXXXXXXXX',\n  'secretAccessKey': 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',\n  'region': 'your-region',\n  'bucket': 'your-bucket-name'\n}");
    }

    cb();
  });
};

s3.push_code = function(cb){
  var s3 = new AWS.S3();

  readdirp({root: path.join(process.cwd(), options.output_folder)}, function(err, res){
    var files = _.pluck(res.files, 'path');
    async.map(files, _put_file, function(err){
      if (err){ return console.error(err); }
      cb();
    });
  });

  cb();

  //
  // private
  //

  function _put_file(file, cb){
    console.log('uploading '.green + file);

    fs.readFile((options.output_folder + '/' + file), function (err, data) {
      if (err) { return console.error(err); }
      s3.putObject({Bucket: AWS.config.bucket, Key: file, Body: data, ContentType: mime.lookup(file) }, function(err, data) {
        if (err) { return console.error(err); }
        cb();
      });
    });
  }


};
