class RootsError extends Error
  constructor: (@name, @message, @ext, @code) ->
    Error.call(@)
    Error.captureStackTrace(@, @constructor)

module.exports = (code, message, ext) ->
  switch code
    when 125 then name = "Malformed Extension"
    when 126 then name = "Malformed Write Hook Output"

  throw new RootsError(name, message, ext, code)
