var roots = require('../index'),
    shell = require('shelljs'),
    analytics = require('../analytics');

var _clean = function(){
  roots.print.log('cleaning...', 'grey');
  shell.rm('-rf', roots.project.path('public'));
  analytics.track_command('clean')
};

module.exports = { execute: _clean };
