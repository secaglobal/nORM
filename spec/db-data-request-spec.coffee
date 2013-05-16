chai = require 'chai'
sinon = require 'sinon'
dataProvider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
MysqlDataRequest = require("#{LIBS_PATH}/mysql/data-request");
MysqlQueryBuilder = require("#{LIBS_PATH}/mysql/query-builder");
Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'

class TestModel extends Model
  @TABLE: 'TestModel'
  @PROXY_ALIAS: 'test2'

chai.should()

describe '@DBDataRequest', () ->
  beforeEach () ->
    dataProvider.registerProxy('test1', new Proxy({test1: true}))
    dataProvider.registerProxy('test2', new Proxy({test2: true}))

    @proxy = dataProvider.getProxy TestModel
    @request = new MysqlDataRequest(@proxy)
    @queryBuilder = new MysqlQueryBuilder()

    @models = new Collection(
      [{id:4, name: 'jako'},{name: 'mona'}, {id: 5, name: 'fill'}],
      {model: TestModel}
    ).models

    sinon.stub(@proxy, 'perform').returns Q.defer().promise;

  afterEach: () ->
    sinon.stub(@proxy, 'perform');


  describe '#save', () ->
    it 'should perfotm save for all changed models', () ->
      @models[0].set name: 'jako1'

      @request.save @models

      updateQuery = @queryBuilder.setTable(TestModel.TABLE).updateFields(name: 'jako1').setFilters(id: 4).compose()
      insertQuery = @queryBuilder.setTable(TestModel.TABLE).insertRows(['name'],[['mona']]).compose()

      @proxy.perform.calledWith(updateQuery).should.be.ok
      @proxy.perform.calledWith(insertQuery).should.be.ok

    it 'should perfotm save for all new models'
    it 'should return promise'

  describe '#delete', () ->
    it 'should perfotm delete for all models that have id'
    it 'should return promise'