global.LIBS_PATH = "#{__dirname}/../lib"

chai = require 'chai'
dataProvider = require "#{LIBS_PATH}/data-provider"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"

chai.should()
global.expect = chai.expect
global.sinon = require 'sinon'

dataProvider.registerProxy("default", new MysqlProxy(
    host      : 'localhost'
))


