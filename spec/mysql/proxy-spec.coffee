chai = require 'chai'
DataRequest = require("#{LIBS_PATH}/mysql/data-request");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
Model = require("#{LIBS_PATH}/model");

chai.should()

describe '@Mysql.Proxy', () ->
  beforeEach () ->
    @proxy = new Proxy {}

  describe '#createDataRequest', () ->
    it 'should return appropriate #DataRequest instance', () ->
      @proxy.createDataRequest(Model).should.be.instanceof DataRequest

  describe '#perform', ()->
    it 'should execute mysql query'
    it 'should returns appropriate list of records'

  describe '#getReadConnection', () ->
    it 'should return read connection to mysql', () ->
      @proxy.getReadConnection().query.should.be.a 'function'

    it 'should return same connection if already created', () ->
      @proxy.getReadConnection().should.be.equal @proxy.getReadConnection()

  describe '#getWriteConnection', () ->
    it 'should return write connection to mysql', () ->
      @proxy.getWriteConnection().query.should.be.a 'function'

    it 'should return same connection if already created', () ->
      @proxy.getWriteConnection().should.be.equal @proxy.getWriteConnection()
