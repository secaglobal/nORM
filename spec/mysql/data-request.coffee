chai = require 'chai'
sinon = require 'sinon'
Model = require "#{LIBS_PATH}/model"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Request = require "#{LIBS_PATH}/mysql/data-request"
Q = require 'q'

class User extends Model
    @TABLE: 'User'

describe '@Mysql.DataRequest', () ->
    beforeEach ()->
        @proxy = new MysqlProxy
        @request = @proxy.createDataRequest()
        @proxyPerformStub = sinon.stub(@proxy, 'perform').returns([
            {id: 1}
        ])

    afterEach ()->
        @proxyPerformStub.restore()