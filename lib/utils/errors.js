var readdirp = require('readdirp'),
    path = require('path'),
    current_directory = path.normalize(process.cwd());

// function: add error messages
// ----------------------------
// adds a specified error message to every html file in the public folder
// 
//    - error: (string) the message to be added
//    - cb: (function) a callback that's executed when finished

var css = "<style> #roots-error { width: 70%; position: absolute; top: 30px; background: #F27258; margin-left: 11%; padding: 19px; border: 5px solid #C93D05; border-radius: 5px; font-family: sans-serif; font-size: 15px; color: white; -webkit-font-smoothing: antialiased; line-height: 1.5em } #roots-error span { display: block; text-align: center; font-size: 1.7em; margin-bottom: 19px; font-weight: bold; } </style>";

exports.add_error_messages = function(error, cb){
  readdirp({ root: path.join(current_directory, 'public'), fileFilter: '*.html' }, function(err, res){
    res.files.forEach(function(file){
      var filepath = path.join(current_directory, 'public', file.path)
      var wrapped_error = "<div id='roots-error'><span>compile error</span>" + error.toString().replace(/(\r\n|\n|\r)/gm, "<br>") + "</div>" + css;
      fs.writeSync(fs.openSync(filepath, 'a+'), wrapped_error, null, 'utf-8');
    });
    cb();
  });
}

// is there a better way to do this? don't see one now. it can not be
// part of the compile process, as an error could occur anywhere along
// the process, even after the html files have already been compiled