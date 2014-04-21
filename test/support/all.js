var path = require('path'),
    fs = require('fs'),
    chai = require('chai'),
    sinon = require('sinon'),
    chai_as_promised = require('chai-as-promised'),
    sinon_chai = require('sinon-chai'),
    chai_fs = require('chai-fs'),
    W = require('when'),
    Roots = require('../..'),
    RootsUtil = require('roots-util').Helpers,
    base_path = path.join(__dirname, '../fixtures');

chai.should();

chai.use(chai_as_promised);
chai.use(sinon_chai);
chai.use(chai_fs);

global.W = W;
global.sinon = sinon;
global.Roots = Roots;
global.path = path;
global.fs = fs;
global.base_path = base_path;
global.util = new RootsUtil({ base: base_path });
