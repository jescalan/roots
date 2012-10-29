
// list of all available top-level roots commands

module.exports = {
  'configure':  require('./configure')
  , 'new':      require('./new')
  , 'watch':    require('./watch')
  , 'compile':  require('./compile')
  , 'js':       require('./watch')
  , 'deploy':   require('./deploy')
  , 'help':     require('./help')
  , 'update':   require('./update')
  , 'version':  require('./version')
}