chai = require 'chai'
Provider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
DBDataRequest = require("#{LIBS_PATH}/db-data-request");
Model = require("#{LIBS_PATH}/model");

class TestModel extends Model
  @PROXY_ALIAS: 'test2'

chai.should()

describe '@DBDataRequest', () ->
  beforeEach () ->
    @model = new TestModel
    @dataProvider = new Provider.constructor()
    @dataProvider.registerProxy('test1', new Proxy({test1: true}))
    @dataProvider.registerProxy('test2', new Proxy({test2: true}))


  describe '#save', () ->
    it 'should perfotm save for all chenged models'
    it 'should perfotm save for all new models'
    it 'should return promise'

  describe '#delete', () ->
    it 'should perfotm delete for all models that have id'
    it 'should return promise'