###*
 * Right now, this is really just for documentation, but you should extend all
   Adapters off of it because in the future, it could contain other stuff.
###
class Adapter
	###*
	 * An array of formats that this Adapter can take.
	 * @type {Array}
	###
	inputFormats: []

	###*
	 * The format that the Adapter spits out
	 * @type {String}
	###
	outputFormat: ''

	###*
	 * The function that will be called to compile the Asset. 
	 * @param {[type]} file [description]
	 * @param {[type]} options={} [description]
	 * @param {Function} cb [description]
	 * @return {[type]} [description]
	###
	compile: (file, options={}, cb) -> return

module.exports = Adapter
