var jade = require('../lib/compilers/jade'),
    haml = require('../lib/compilers/haml'),
    ejs = require('../lib/compilers/ejs'),
    helpers = require('../lib/helpers');

exports.get_formats = function get_formats(files) {
  return [{func: jade.compile, files: files.jade},
          {func: haml.compile, files: files.haml},
          {func: ejs.compile, files: files.ejs},
          {func: helpers.pass_through, files: files.html}];
}