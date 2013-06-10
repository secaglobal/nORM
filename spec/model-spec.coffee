Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'
Person = require('./models')['Person']

describe '@Model', () ->
    beforeEach () ->
        @stive = new Person
            name: 'Stive',
            age: 18,
            cars: [{title: 'BMW'}, {title: 'Lada'}]

        @deferred = Q.defer()

        sinon.stub(Collection.prototype, 'require').returns @deferred.promise

    afterEach () ->
        Collection.prototype.require.restore()

    describe '#constructor', () ->
        it 'should provide access to first level fields', () ->
            expect(@stive.name).be.equal 'Stive'
            expect(@stive.age).be.equal 18

        it 'should provide access to relations', () ->
            expect(@stive.cars).instanceof Collection
            expect(@stive.cars.first().title).be.equal 'BMW'
            expect(@stive.cars.at(1).title).be.equal 'Lada'

        it 'should save original values', () ->
            @stive.name = 'other name'
            expect(@stive.original.name).be.equal 'Stive'

    describe '#require', () ->
        it 'should pass fields to parent collection', () ->
            res = @stive.require 'cars', 'task,', 'job'

            expect(Collection.prototype.require.calledWith('cars', 'task,', 'job')).be.ok
            expect(res).be.equal @deferred.promise


#    beforeEach () ->
#        @deferred =Q.defer()
#        @model = new TestModel()
#        @request = new DBDataRequest
#        sinon.stub(dataProvider, 'createRequest').returns @request
#        sinon.stub(@request, 'fillManyToOneRelation').returns @deferred.promise
#        sinon.stub(@request, 'fillOneToManyRelation').returns @deferred.promise
#        sinon.stub(@request, 'fillManyToManyRelation').returns @deferred.promise
#
#    afterEach () ->
#        dataProvider.createRequest.restore()
#        @request.fillManyToOneRelation.restore()
#        @request.fillOneToManyRelation.restore()
#        @request.fillManyToManyRelation.restore()
#        delete TestModel.relation_test
#        @model.clearRelations()
#
#    describe '#getProxyAlias', () ->
#        it 'should return default proxy alias', () ->
#            proxy = FirstModel.getProxyAlias()
#            proxy.should.be.equal 'default'
#
#        it 'should return redefined proxy alias', () ->
#            proxy = TestModel.getProxyAlias()
#            proxy.should.be.equal 'test2'
#
#    describe '#addRelation', () ->
#        it 'should add method for interaction with relations', () ->
#            TestModel.addRelation 'relation_test', {}
#
#            expect(TestModel::relation_test).be.a 'function'
#
#        it 'should fill #relations with suitable config', ()->
#            config = type: TestModel.RELATION_TYPE__ONE_TO_ONE
#
#            TestModel.addRelation 'relation_test', config
#
#            expect(TestModel::relation_test.config).be.equal config
#
#    describe '#benongTo result execution', () ->
#        it 'should call @DataRequest #fillManyToOneRelation', () ->
#            @model.relation1()
#            @request.fillManyToOneRelation.calledWith([@model], 'relation1').should.be.ok
#
#        it 'should return promise', () ->
#            res = @model.relation1()
#            expect(res).to.be.instanceof Q.defer().promise.constructor
#
##        it 'should pass related object to promise callback', (done) ->
##            @model.relation1().then (instance) ->
##                try
##                    expect(instance).to.be.instanceof FirstModel
##                    instance.get(id).should.be
#
#    describe '#hasMany result execution', () ->
#        it 'should call @DataRequest #fillOneToManyRelation', () ->
#            @model.relation2()
#            @request.fillOneToManyRelation.calledWith([@model], 'relation2').should.be.ok
#
#        it 'should return promise', () ->
#            res = @model.relation2()
#            expect(res).to.be.instanceof Q.defer().promise.constructor
#
#    describe '#hasAndBelongsToMany result execution', () ->
#        it 'should call @DataRequest #fillManyToManyRelation', () ->
#            @model.relation3()
#            @request.fillManyToManyRelation.calledWith([@model], 'relation3').should.be.ok
#
#        it 'should return promise', () ->
#            res = @model.relation3()
#            expect(res).to.be.instanceof Q.defer().promise.constructor






#    it 'should set up @DataRequest and execute perform', () ->
#
#    it 'should return promise'
#    it 'should pass Model when request will be executed'
