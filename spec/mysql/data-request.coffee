chai = require 'chai'
sinon = require 'sinon'
Model = require "#{LIBS_PATH}/model"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Request = require "#{LIBS_PATH}/mysql/data-request"

chai.should()

class User extends Model
  @TABLE: 'User'

describe '@Mysql.DataRequest', () ->
  beforeEach ()->
    @proxy = new MysqlProxy
    @request = @proxy.createDataRequest()
    @proxyPerformStub = sinon.stub(@proxy, 'perform').returns([
      {id: 4, name: 'Nike'}
    ])

  afterEach ()->
    @proxyPerformStub.restore()

  describe '#perform', () ->
    it 'should prepare query and execute via @DataProxy#query', () ->
      @request.setFilters({id: 4, state: {$ne: 5}}).find(User)
      @proxyPerformStub.called.should.be.ok
