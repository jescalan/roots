var connect = require('connect'),
    roots = require('../../../index');

var app = connect()
  .use(connect.logger('dev'))
  .use(connect.static('public'))
  .listen(process.env.PORT || 3000);

roots.print.log("-- Server started on port " + (process.env.PORT || 3000) + " --");
