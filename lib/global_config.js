var fs = require('fs'),
    path = require('path'),
    ConfigStore = require('configstore')

var tmpl_path = path.join(__dirname, '../templates/global_config/default.json');
var tmpl = JSON.parse(fs.readFileSync(tmpl_path, 'utf8'));
var store = new ConfigStore('roots', tmpl);

module.exports = store;
