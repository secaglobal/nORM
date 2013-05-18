chai = require 'chai'

global.LIBS_PATH = "#{__dirname}/../lib"

chai.should()
global.expect = chai.expect
global.sinon = require 'sinon'


