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
        @collection = new Collection [], {model: TestModel, order: {id: -1}, limit: 10, offset: 1, filters:
            id: {$in: [4,5]}
        }

        @deferred = Q.defer()
        sinon.stub(@collection.getRequest(), 'find').returns @deferred.promise
        sinon.stub(@collection.getRequest(), 'save').returns @deferred.promise
        sinon.stub(@collection.getRequest(), 'delete').returns @deferred.promise
        sinon.stub(@collection.getRequest(), 'setOrder').returns @collection.getRequest()
        sinon.stub(@collection.getRequest(), 'setLimit').returns @collection.getRequest()
        sinon.stub(@collection.getRequest(), 'setOffset').returns @collection.getRequest()
        sinon.stub(@collection.getRequest(), 'setFilters').returns @collection.getRequest()

    afterEach () ->
        @collection.getRequest().find.restore()
        @collection.getRequest().setLimit.restore()
        @collection.getRequest().setOffset.restore()
        @collection.getRequest().setOrder.restore()
        @collection.getRequest().setFilters.restore()
        @collection.getRequest().save.restore()
        @collection.getRequest().delete.restore()

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

            @deferred.resolve([
                {id: 4}
            ])

        it 'should pass collection as first argument for resolved promise', () ->
            _ = @
            @collection.load().then (col)->
                try
                    _.collection.should.be.equal col
                    done()
                catch err
                    done err

            @deferred.resolve([
                {id: 4}
            ])

        it 'should use filters', ()->
            @collection.load()
            @collection.getRequest().setFilters.called.should.be.ok
            expect(@collection.getRequest().setFilters.args[0][0]).be.ok
            @collection.getRequest().setFilters.calledWith(@collection._filters).should.be.ok

        it 'should use limit', ()->
            @collection.load()
            @collection.getRequest().setLimit.called.should.be.ok
            expect(@collection.getRequest().setLimit.args[0][0]).be.ok
            @collection.getRequest().setLimit.calledWith(@collection._limit).should.be.ok

        it 'should use offset', ()->
            @collection.load()
            @collection.getRequest().setOffset.called.should.be.ok
            expect(@collection.getRequest().setOffset.args[0][0]).be.ok
            @collection.getRequest().setOffset.calledWith(@collection._offset).should.be.ok

        it 'should use order', ()->
            @collection.load()
            @collection.getRequest().setOrder.called.should.be.ok
            expect(@collection.getRequest().setOrder.args[0][0]).be.ok
            @collection.getRequest().setOrder.calledWith(@collection._order).should.be.ok

    describe '#save', () ->
        it 'should pass all models to @DataRequest#save', () ->
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            @collection.save()

            @collection.getRequest().save.calledWith(@collection.models).should.be.ok

        it 'should return promise', () ->
            expect(@collection.save()).to.be.deep.instanceof @deferred.promise.constructor

    describe '#delete', () ->
        it 'should pass all models to @DataRequest#delete', () ->
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            @collection.delete()

            @collection.getRequest().delete.calledWith(@collection.models).should.be.ok

        it 'should return promise', () ->
            expect(@collection.delete()).to.be.deep.instanceof @deferred.promise.constructor

        it 'should reset models array if success', (done) ->
            _ = @
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]

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
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            models = @collection.models

            @collection.delete().then null, (err) ->
                try
                    _.collection.models.should.be.deep.equal models
                    done()
                catch err
                    done err

            @deferred.reject('something happen')

