var connect = require('connect');

var app = connect()
  .use(connect.logger('dev'))
  .use(connect.static('public'))
  .listen(process.env.PORT || 3000);

console.log("-- Server started on port " + (process.env.PORT || 3000) + " --");
