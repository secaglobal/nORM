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

describe '@DBDataRequest', () ->
  beforeEach () ->
    dataProvider.registerProxy('test1', new Proxy({test1: true}))
    dataProvider.registerProxy('test2', new Proxy({test2: true}))

    @proxy = dataProvider.getProxy TestModel
    @request = new MysqlDataRequest(@proxy)
    @queryBuilder = new MysqlQueryBuilder()

    @models = new Collection(
      [
        {id:4, name: 'jako', age: 20},
        {name: 'mona'},
        {name: 'mona2'},
        {name: 'mona3', age: 30},
        {id: 5, name: 'fill'}
        {id:7, name: 'fifa'},
      ],
      {model: TestModel}
    ).models

    sinon.stub(@proxy, 'perform').returns Q.defer().promise;

  afterEach: () ->
    sinon.stub(@proxy, 'perform');


  describe '#save', () ->
    it 'should perfotm save for all changed models', () ->
      updateQuery1 = @queryBuilder.setTable(TestModel.TABLE).updateFields({name: 'jako1'}).setFilters(id: 4).compose()
      updateQuery2 = @queryBuilder.setTable(TestModel.TABLE).updateFields({name: 'fifaEdited', age: 40}).setFilters(id: 7).compose()

      @models[0].set name: 'jako1'
      @models[5].set name: 'fifaEdited', age: 40

      @request.save @models

      @proxy.perform.calledWith(updateQuery1).should.be.ok
      @proxy.perform.calledWith(updateQuery2).should.be.ok


    it 'should perfotm save for all new models', () ->
      insertQuery1 = @queryBuilder.setTable(TestModel.TABLE).setFields(['name']).insertValues([['mona'],['mona2']]).compose()
      insertQuery2 = @queryBuilder.setTable(TestModel.TABLE).setFields(['age', 'name']).insertValues([[30, 'mona3']]).compose()

      @request.save @models

      @proxy.perform.calledWith(insertQuery1).should.be.ok
      @proxy.perform.calledWith(insertQuery2).should.be.ok

    it 'should return promise', () ->
      expect(@request.save @models).to.be.instanceof Q.allResolved([]).constructor

  describe '#delete', () ->
    it 'should perfotm delete for all models that have id', () ->
      deleteQuery = @queryBuilder.setType(MysqlQueryBuilder.TYPE__DELETE).setTable(TestModel.TABLE).setFilters({id: {$in: [4,5,7]}}).compose()

      @request.delete @models

      @proxy.perform.calledWith(deleteQuery).should.be.ok


    it 'should return promise', () ->
      @request.delete @models
      expect(@request.save @models).to.be.instanceof Q.defer().promise.constructor