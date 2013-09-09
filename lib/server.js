var connect = require('connect'),
    express = require('express'),
    colors = require('colors'),
    path = require('path'),
    http = require('http'),
    open = require('open'),
    roots = require('./index');

rootsBrowserAssets = function (req, res, next) {
  var snippet = '<script src="/__roots__/main.js" type="text/javascript"></script>';

  var bodyExists = function (body) {
    if (!body) return false;
    return (~body.lastIndexOf("</body>"));
  };

  var snippetExists = function (body) {
    if (!body) return true;
    return (~body.lastIndexOf(snippet));
  };

  var acceptsHtmlExplicit = function (req) {
    var accept = req.headers["accept"];
    if (!accept) return false;
    return (~accept.indexOf("html"));
  };

  var isExcluded = function (req) {
    var excludeList = ['.woff', '.js', '.css', '.ico'];
    var url = req.url;
    var excluded = false;
    if (!url) return true;
    excludeList.forEach(function(exclude) {
      if (~url.indexOf(exclude)) {
        excluded = true;
      }
    });
    return excluded;
  };

  var writeHead = res.writeHead;
  var write = res.write;
  var end = res.end;

  if (!acceptsHtmlExplicit(req) || isExcluded(req)) {
    return next();
  }

  res.push = function(chunk) {
    res.data = (res.data || '') + chunk;
  };

  res.inject = res.write = function(string, encoding) {
    res.write = write;
    if (string !== undefined) {
      var body = string instanceof Buffer ? string.toString(encoding) : string;
      if ((bodyExists(body) || bodyExists(res.data)) && !snippetExists(body) && (!res.data || !snippetExists(res.data))) {
        res.push(body.replace(/<\/body>/, function(w) {
          return snippet + w;
        }));
        return true;
      } else {
        return res.write(string, encoding);
      }
    }
    return true;
  };

  res.end = function(string, encoding) {
    res.writeHead = writeHead;
    res.end = end;
    var result = res.inject(string, encoding);
    if (!result) return res.end(string, encoding);
    if (res.data !== undefined && !res._header) res.setHeader('content-length', Buffer.byteLength(res.data, encoding));
    res.end(res.data, encoding);
  };
  next();
};


exports.start = function(serve_dir){
  var port = process.env.PORT || 1111;
  var app = express();

  if (roots.project.conf('mode') == 'dev'){
    app.use('/__roots__', connect.static(path.resolve(__dirname, 'browser_assets')));
    app.get('/__roots__/conf.json', function(req, res){
      // we could expose a bunch of other stuff, I just don't feel like it right now
      res.send(JSON.stringify({livereloadEnabled: roots.project.conf('livereloadEnabled')}));
    });
    app.use(rootsBrowserAssets);
  }
  app.use(connect.static(serve_dir));
  if (roots.project.conf('debug')) app.use(connect.logger('dev'));

  var server = exports.server = http.createServer(app).listen(port);
  open('http://localhost:' + port);

  roots.print.log('server started on port ' + port, 'green');
};
