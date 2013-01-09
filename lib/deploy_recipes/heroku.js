
var heroku = module.exports = {};

heroku.create_project = function(){
  console.log('creating app on heroku...'.grey);
  if (name.length < 1) { name = "" } else { name = name[0] };

  run('heroku create ' + name, function(err, out){
    if (err) { return console.error(err) };
    var url = out.match(/(http:\/\/.*\/)/)[1]
    console.log('new heroku app created at '.green + url.green);
    cb();
  });
}

heroku.push_code = function(cb){
  console.log('pushing master branch to heroku (this may take a few seconds)...'.grey);

  run('git push heroku master', function(err, out){
    if (err) { return console.error(err) };
    console.log('heroku app launched'.grey);
    cb();
  });
}

heroku.commit = function(cb){
  run("git add .; git commit -am 'compress and deploy'", function(err){
    if (err) { return console.error(err) };
    console.log('comitting heroku config files to git...'.grey);
    cb();
  });
}

heroku.add_config_files = function(cb){
  var source = path.join(__dirname, '../../templates/heroku') + "/*";
  var destination = process.cwd();
  shell.cp('-rf', source, destination);
  console.log('heroku config files copied...'.grey);
  cb();
}

heroku.done = function(err){
  if (err) { return console.error(err) };
  console.log('done!'.green)
}