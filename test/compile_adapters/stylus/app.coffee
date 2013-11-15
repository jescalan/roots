autoprefixer = module.require('autoprefixer-stylus')

module.exports = 

  ignore_files: ['_*']
  ignore_folders: ['autoprefixer']

  stylus:
    plugins: ['axis-css', autoprefixer]
