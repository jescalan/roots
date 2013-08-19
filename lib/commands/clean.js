var roots = require('../index'),
    shell = require('shelljs');

var _clean = function(){
  roots.print.log('cleaning...', 'grey');
  shell.rm('-rf', roots.project.path('public'));
};

module.exports = { execute: _clean };
