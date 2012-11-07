var bower = require('bower');

var _js = function(command){

  // had to fork bower to expose the config api
  bower.config.directory = "assets/js/components";

  bower.commands[command[0] || 'help'].line(['node', __dirname].concat(command))
    .on('data',  function (data) { data && console.log(data); })
    .on('end',   function (data) { data && console.log(data); })
    .on('error', function (err)  { throw err })
}

module.exports = { execute: _js, needs_config: true }