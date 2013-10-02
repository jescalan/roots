class DynamicContentExtension

  compile_hook: (deferred) ->
    intermediate = (@adapters.length > @index)
    @fh.parse_dynamic_content() unless intermediate
    deferred.resolve(@)

module.exports = DynamicContentExtension
