
// Utilities
// ---------
// Used heavily in the main compilation process. Separated out
// here for better organization and modularity

module.exports = {
    compile_files:      require('./compile_files')
  , create_structure:   require('./create_structure')
  , add_error_messages: require('./errors')
  , process_images:     require('./process_images')
}