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
var client;

s3.check_credentials = function(cb){
  var config_file_path = './s3.json'

  fs.exists(config_file_path, function(exists) {
    if (exists) {
      var config        = JSON.parse(AWS.util.readFileSync(config_file_path));
      AWS.config        = new AWS.Config(config);
      AWS.config.bucket = config.bucket
      client            = new AWS.S3();
    } else {
      return console.error("no S3 config file present. please create s3.json in the current directory with the proper configuration:\n\n{\n  'accessKeyId': 'XXXXXXXXXXXXXXXXXXXXXX',\n  'secretAccessKey': 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',\n  'region': 'your-region',\n  'bucket': 'your-bucket-name'\n}");
    }

    cb();
  });
};


s3.create_project = function(cb){
  client.getBucketWebsite({Bucket: AWS.config.bucket}, function(err, data){
    if (err) {
      if (err.code == 'NoSuchWebsiteConfiguration'){ _create_site_config(); }
      else { return console.error(err); }
    }
  });

  cb();

  //
  // private
  //

  function _create_site_config(){
    var site_config = {
      Bucket: AWS.config.bucket,
      WebsiteConfiguration: {
        IndexDocument: {
          Suffix: 'index.html'
        }
      }
    }

    client.putBucketWebsite(site_config, function(err, data){
      if (err) { return console.error(err); }
    });
  }

};


s3.push_code = function(cb){

  readdirp({root: path.join(process.cwd(), options.output_folder)}, function(err, res){
    var files = _.pluck(res.files, 'path');

    async.map(files, _put_file, function(err){
      if (err){ return console.error(err); }
      console.log("success!".green + " your site has been deployed to: http://" + AWS.config.bucket + ".s3-website-" + AWS.config.region + ".amazonaws.com/");
      cb();
    });

  });

  //
  // private
  //

  function _put_file(file, cb){
    fs.readFile((path.join(options.output_folder, file)), function (err, data) {
      if (err) { throw err }
      client.putObject({Bucket: AWS.config.bucket, Key: file, Body: data, ACL: 'public-read', ContentType: mime.lookup(file) }, function(err, data) {
        if (err) { throw err }
        console.log('uploaded '.green + file);
        cb();
      });
    });
  }

};
