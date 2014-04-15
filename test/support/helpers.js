global.compile_fixture = function(p, done, tests){
  var project = new Roots(p);
  project.compile().done(tests, done);
}

global.paths_exist = function(p, arr){
  arr.forEach(function(f){
    path.join(p, f).should.be.a.path()
  });
}

global.paths_dont_exist = function(p, arr){
  arr.forEach(function(f){
    path.join(p, f).should.not.be.a.path()
  });
}

global.matches_file = function(p, a, b){
  path.join(p, a).should.have.content(fs.readFileSync(path.join(p, b), 'utf8'));
}
