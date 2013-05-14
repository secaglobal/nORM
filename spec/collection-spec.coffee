chai = require 'chai'
sinon = require 'sinon'
Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Q = require 'q'

dataProvider = require("#{LIBS_PATH}/data-provider")
chai.should()
expect = chai.expect

class TestModel extends Model
  @PROXY_ALIAS: 'testProxy'

describe '@Collection', () ->
  before () ->
    dataProvider.registerProxy('testProxy', new MysqlProxy {})

  beforeEach () ->
    @collection = new Collection [], {model: TestModel}
    @deferred = Q.defer()
    sinon.stub(@collection.getRequest(), 'find').returns @deferred.promise


  afterEach () ->
    @collection.getRequest().find.restore()

  describe '#load', () ->
    it 'should request rows via model proxy', () ->
      @collection.load()
      @collection.getRequest().find.called.should.be.ok
      @collection.getRequest().find.calledWith(TestModel).should.be.ok

    it 'should return @DataRequest#find result', () ->
      expect(@collection.load()).to.be.deep.equal @deferred.promise

    it 'should fill collection with received models', () ->
      @collection.load()
      @deferred.resolve([{id: 4}])
      @collection.length.should.be.equal 1

  describe '#save', () ->
    it 'should save all changed models'
    it 'should return promise'

  describe 'delete', () ->
    it 'should delete all changed models'
    it 'should return promise'
