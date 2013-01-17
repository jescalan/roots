exports.set = function(app) {
  app.get('/', homePage);
}

/*
 * GET home page.
 */
function homePage(req, res) {
  res.render('index', { title: 'Express' });
}