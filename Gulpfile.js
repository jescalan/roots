var g = require('gulp'),
    coffee = require('gulp-coffee');

g.task('build', function(){
  g.src('src/**/*.coffee').pipe(coffee()).pipe(g.dest('lib'))
});
