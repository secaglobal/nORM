Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Q = require 'q'

dataProvider = require("#{LIBS_PATH}/data-provider")

class TestModel extends Model
  @PROXY_ALIAS: 'testProxy'

describe '@Collection', () ->
  before () ->
    dataProvider.registerProxy('testProxy', new MysqlProxy {})

  beforeEach () ->
    @collection = new Collection [], {model: TestModel}
    @deferred = Q.defer()
    sinon.stub(@collection.getRequest(), 'find').returns @deferred.promise
    sinon.stub(@collection.getRequest(), 'save').returns @deferred.promise
    sinon.stub(@collection.getRequest(), 'delete').returns @deferred.promise

  afterEach () ->
    @collection.getRequest().find.restore()

  describe '#load', () ->
    it 'should request rows via model proxy', () ->
      @collection.load()
      @collection.getRequest().find.called.should.be.ok
      @collection.getRequest().find.calledWith(TestModel).should.be.ok

    it 'should return promise', () ->
      expect(@collection.load()).to.be.deep.instanceof @deferred.promise.constructor

    it 'should fill collection with received models', (done) ->
      _ = @
      @collection.load().then ()->
        try
          _.collection.length.should.be.equal 1
          done()
        catch err
          done err
      @deferred.resolve([{id: 4}])

  describe '#save', () ->
    it 'should pass all models to @DataRequest#save', () ->
      @collection.reset [{id: 1, name: 'lego'} ,{name: 'mike'}]
      @collection.save()

      @collection.getRequest().save.calledWith(@collection.models).should.be.ok

    it 'should return promise', () ->
      expect(@collection.save()).to.be.deep.instanceof @deferred.promise.constructor

  describe 'delete', () ->
    it 'should pass all models to @DataRequest#delete', () ->
      @collection.reset [{id: 1, name: 'lego'} ,{name: 'mike'}]
      @collection.delete()

      @collection.getRequest().delete.calledWith(@collection.models).should.be.ok

    it 'should return promise', () ->
      expect(@collection.delete()).to.be.deep.instanceof @deferred.promise.constructor

    it 'should reset models array if success', (done) ->
      _ = @
      @collection.reset [{id: 1, name: 'lego'} ,{name: 'mike'}]

      @collection.delete().then(() ->
        try
          _.collection.models.should.be.deep.equal []
          done()
        catch err
          done err
      )

      @deferred.resolve(123)

    it 'should keep models array if false', (done) ->
      _ = @
      @collection.reset [{id: 1, name: 'lego'} ,{name: 'mike'}]
      models = @collection.models

      @collection.delete().then null, (err) ->
        try
          _.collection.models.should.be.deep.equal models
          done()
        catch err
          done err

      @deferred.reject('something happen')

