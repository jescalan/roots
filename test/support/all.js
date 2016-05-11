var path = require('path')
var fs = require('fs')
var chai = require('chai')
var sinon = require('sinon')
var chai_as_promised = require('chai-as-promised')
var sinon_chai = require('sinon-chai')
var chai_fs = require('chai-fs')
var W = require('when')
var Roots = require('../..')
var RootsUtil = require('roots-util').Helpers
var base_path = path.join(__dirname, '../fixtures')

chai.should()

chai.use(chai_as_promised)
chai.use(sinon_chai)
chai.use(chai_fs)

global.W = W
global.sinon = sinon
global.chai = chai
global.Roots = Roots
global.path = path
global.fs = fs
global.base_path = base_path
global.util = new RootsUtil({ base: base_path })
