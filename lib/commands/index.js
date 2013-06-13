// list of all available top-level roots commands

module.exports = {
  'new':      require('./new'),
  'watch':    require('./watch'),
  'compile':  require('./compile'),
  'pkg':      require('./pkg'),
  'plugin':   require('./plugin'),
  'deploy':   require('./deploy'),
  'help':     require('./help'),
  'version':  require('./version'),
  'template': require('./template')
};
