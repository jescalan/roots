var path = require('path'),
    fs = require('fs'),
    _ = require('underscore'),
    output_path = require('./output_path'),
    yaml_parser = require('./yaml_parser');

module.exports = function(file){
  f = {};

  // base variables
  f.path = file;
  f.contents = fs.readFileSync(file, 'utf8');
  f.export_path = output_path(file);
  f.extension = path.basename(f.path).split('.')[1];
  f.target_extension = path.basename(f.export_path).split('.')[1];

  // dynamic content handling
  yaml_parser.match(f.contents) && handle_dynamic_content();

  // layout handling
  Object.keys(global.options.layouts).length > 0 && f.target_extension == 'html' && set_layout();

  // handling for locals
  f.locals = locals;

  // write file
  f.write = write;

  return f

  // 
  // @api private
  // 

  // ?= or ||=, very slightly less painful
  function oeq(a,b){ if (!a) { return b } else { return a }; }

  function handle_dynamic_content(){
    var front_matter_string = yaml_parser.match(f.contents);

    // set up variables
    f.category_name = f.path.replace(process.cwd(),'').split(path.sep)[1];
    options.locals.site = oeq(options.locals.site, {});
    options.locals.site[f.category_name] = oeq(options.locals.site[f.category_name], []);
    f.dynamic_locals = {};

    // load variables from front matter
    var front_matter = yaml_parser.parse(f.contents, { filename: f.file })
    for (var k in front_matter) {
      f.dynamic_locals[k] = front_matter[k];
    }
    
    // if layout is present, set the layout and single post url
    if (front_matter.layout){
      try {
        f.layout_path = path.resolve(path.dirname(f.path), front_matter.layout);
      } catch (err) {
        console.log(err)
      }
      f.dynamic_locals.url = f.path.replace(process.cwd(), '').replace(/\..*$/, '.html');
    }

    // add to global locals (hah)
    options.locals.site[f.category_name].push(f.dynamic_locals);

    // remove the front matter
    f.contents = f.contents.replace(front_matter_string[0], '');
  }

  function set_layout(){
    if (!f.layout_path){
      var layout = options.layouts.default;
      for (var key in options.layouts){
        if (key === file) { layout = options.layouts[key] }
      }
      f.layout_path = path.join(process.cwd(), options.folder_config.views, layout);
    }
    f.layout_contents = fs.readFileSync(f.layout_path, 'utf8');
  }

  function locals(extra){
    var locals = _.clone(global.options.locals);

    // add path variable
    locals.path = f.export_path;

    // add any extra locals
    for (var key in extra){ locals[key] = extra[key]; }

    // add dynamic locals if needed
    if (f.dynamic_locals) {
      locals.post = f.dynamic_locals;
      if (extra && extra.hasOwnProperty('yield')){
        f.dynamic_locals.content = extra.yield;
      }
    }

    return locals
  }

  function write(write_content){

    // if dynamic and no layout, don't write
    if (f.dynamic_locals && !f.dynamic_locals.layout) {
      global.options.debug.log("processed " + f.path.replace(process.cwd(),''));
      return false
    }

    // compress if needed
    if (global.options.compress) { write_content = compress(write_content) }

    // write it
    fs.writeFileSync(f.export_path, write_content);
    global.options.debug.log("compiled " + f.path.replace(process.cwd(),''));

  }

  function compress(write_content){
    return require('./compressor')(write_content, f.target_extension)
  }

}