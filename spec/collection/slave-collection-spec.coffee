MysqlProxy = require("#{LIBS_PATH}/mysql/proxy");
Collection = require("#{LIBS_PATH}/collection/collection");
SlaveCollection = require("#{LIBS_PATH}/collection/slave-collection");
Q = require 'q'
Person = require('./../models')['Person']
Car = require('./../models')['Car']

dataProvider = require("#{LIBS_PATH}/data-provider")

describe '@Collection', () ->
    before () ->
        dataProvider.registerProxy('default', new MysqlProxy {})

    beforeEach () ->
        @collection = new SlaveCollection [], {
            model: Person,
            fields: ['id', 'tasks']
            filters:
                jobId: 4
        }

        @deferred = Q.defer()

        sinon.spy(Collection.prototype, 'load')
        sinon.spy(Collection.prototype, 'delete')
        sinon.spy(Collection.prototype, 'save')
        sinon.stub(MysqlProxy.prototype, 'perform').returns @deferred.promise

    afterEach () ->
        Collection.prototype.load.restore()
        Collection.prototype.delete.restore()
        Collection.prototype.save.restore()
        MysqlProxy.prototype.perform.restore()

    describe '#save', () ->
        it 'should delete all models appropriate to filters but absent in collection', (done) ->
            @collection.reset([{id: 5, name: 'A'}, {id: 6, name: 'B'}]).save()
                .then () ->
                    expectedFilter = id: {$nin: [5,6]}, jobId: 4
                    loadSpy = Collection.prototype.load
                    expect(loadSpy.calledOnce).be.ok
                    expect(Collection.prototype.delete.calledOnce).be.ok
                    expect(loadSpy.firstCall.thisValue.config.filters).be.deep.equal expectedFilter
                    expect(loadSpy.firstCall.thisValue.config.limit).be.undefined
                    done()
                .fail done

            @deferred.resolve([{id: 76}])

        it 'should do not call delete if nothing to delete', (done) ->
            @collection.reset([{id: 5, name: 'A'}, {id: 6, name: 'B'}]).save()
            .then () ->
                    expect(Collection.prototype.load.calledOnce).be.ok
                    expect(Collection.prototype.delete.called).be.not.ok
                    done()
            .fail done

            @deferred.resolve([])

        it 'should save other objects', (done) ->
            @collection.reset([{id: 5, name: 'A'}, {id: 6, name: 'B'}]).save()
                .then () ->
                        expect(Collection.prototype.save.calledOnce).be.ok
                        done()
                .fail done

            @deferred.resolve([])

        it 'should fail if no filters will be used', (done) ->
            @collection = new SlaveCollection [], {
                model: Person,
                fields: ['id', 'tasks']
                filters: {}
            }

            @collection.save()
                .then () ->
                    done('should failed')
                .fail () ->
                    done()

            @deferred.resolve([])




    describe '#assignParentModel', ()->
        it 'should set parent id for all models', () ->
            col = new SlaveCollection([{title: 'x'}], {model: Car})
            col.assignParentModel(new Person({id: 7}))
            expect(col.first()[Person.schema.defaultFieldName]).be.equal 7


        it 'should set filter with parentId field', () ->
            col = new SlaveCollection([{title: 'x'}], {model: Car})
            col.assignParentModel(new Person({id: 7}))
            expect(col.config.filters[Person.schema.defaultFieldName]).be.equal 7




