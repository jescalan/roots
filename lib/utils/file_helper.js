var path = require('path'),
    fs = require('fs'),
    _ = require('underscore'),
    output_path = require('./output_path'),
    yaml_parser = require('./yaml_parser');

module.exports = function(file){
  f = {};

  // set paths
  f.path = file;
  f.contents = fs.readFileSync(file, 'utf8');
  f.export_path = output_path(file);
  f.extension = path.basename(f.path).split('.')[1];
  f.target_extension = path.basename(f.export_path).split('.')[1];

  // expose public api
  f.parse_dynamic_content = parse_dynamic_content;
  f.set_layout = set_layout;
  f.locals = locals;
  f.write = write;

  return f

  // 
  // @api public
  // 

  // depends on set_paths
  function parse_dynamic_content(){
    var front_matter_string = yaml_parser.match(f.contents);

    if (front_matter_string) {

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
        f.layout_path = path.resolve(path.dirname(f.path), front_matter.layout);
        f.layout_contents = fs.readFileSync(f.layout_path, 'utf8');
        f.dynamic_locals.url = f.path.replace(process.cwd(), '').replace(/\..*$/, '.html');
      }

      // add to global locals (hah)
      options.locals.site[f.category_name].push(f.dynamic_locals);

      // remove the front matter
      f.contents = f.contents.replace(front_matter_string[0], '');

    } else {
      return false
    }
  }

  // depends on set_paths and parse_dynamic_content
  function set_layout(){

    // make sure a layout actually has to be set
    var layouts_set = Object.keys(global.options.layouts).length > 0;
    var html_file = f.target_extension == 'html';

    if (layouts_set && html_file && !f.dynamic_locals) {

      // pull the default layout initially
      var layout = options.layouts.default;

      // if there's a custom override, use that instead
      for (var key in options.layouts){
        if (key === file) { layout = options.layouts[key] }
      }

      // set the layout path and contents
      f.layout_path = path.join(process.cwd(), options.folder_config.views, layout);
      f.layout_contents = fs.readFileSync(f.layout_path, 'utf8');

    } else {
      return false
    }

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

      // if dynamic with content, add the compiled content to the locals
      if (write_content !== ''){
        var category = options.locals.site[f.category_name]
        category[category.length-1].content = write_content;
      }
      
      // don't write the file
      global.options.debug.log("processed " + f.path.replace(process.cwd(),''));
      return false
    }

    // compress if needed
    if (global.options.compress) { write_content = compress(write_content) }

    // write it
    fs.writeFileSync(f.export_path, write_content);
    global.options.debug.log("compiled " + f.path.replace(process.cwd(),''));

  }

  // 
  // @api private
  // 

  // ?= or ||=, very slightly less painful
  function oeq(a,b){ if (!a) { return b } else { return a }; }

  function compress(write_content){
    return require('./compressor')(write_content, f.target_extension)
  }

}