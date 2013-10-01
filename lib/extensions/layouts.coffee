class LayoutsExtension

  after_hook: (deferred) ->
    if !(@adapters.length - @index - 1 > 0)
      process_layout.call @, @fh, @adapter, (contents) =>
        @fh.write(contents)
        deferred.resolve(@)

  ###*
   * Compliles a given file into it's layout.
   * @param {FileHelper} fh - file helper for a given file
   * @param {Adapter} adapter - adapter that can be used to compile the given file
   * @param {Function} cb - callback when finished
   * @private
  ###

  compile_into_layout = (fh, adapter, cb) ->
    layout_file =
      contents: fh.layout_contents
      path: fh.layout_path

    adapter.compile layout_file, fh.locals(content: fh.contents), (err, layout) =>
      if err then return @emit('error', err)
      cb(layout)

  ###*
   * If necessary, sets up layout information and compiles content into
   * it's template. Returns the content ready to write.
   * @param  {FileHelper} fh - FileHelper instance
   * @param  {Adapter} adapter - Adapter needed to compile
   * @return {string} content to write
   * @private
  ###

  process_layout = (fh, adapter, cb) ->
    fh.set_layout() if fh.target_extension is 'html'
    fh.set_dynamic_locals() if !!fh.dynamic_locals
    return compile_into_layout.call(@, fh, adapter, cb) if fh.layout_path
    cb(fh.contents)

module.exports = LayoutsExtension
