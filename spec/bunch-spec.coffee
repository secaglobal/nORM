MysqlProxy = require("#{LIBS_PATH}/mysql/proxy");
Bunch = require("#{LIBS_PATH}/collection/bunch");
Q = require 'q'
dataProvider = require("#{LIBS_PATH}/data-provider")

Person = require('./models')['Person']
Car = require('./models')['Car']

describe '@Bunch', () ->
    before () ->
        dataProvider.registerProxy('default', new MysqlProxy {})

    beforeEach () ->
        @bunch = new Bunch [{title: 'BMW'}], {
            model: Car,
            parent: new Person({id: 4}),
            relation: 'cars',
            order: {id: -1},
            limit: 10,
            offset: 1,
            filters:
                id: {$in: [4,5]}
        }

        @deferred = Q.defer()
        sinon.stub(@bunch.getRequest(), 'save').returns @deferred.promise
        sinon.stub(@bunch.getRequest(), 'saveManyToManyRelations').returns @deferred.promise
        sinon.stub(@bunch.getRequest(), 'delete').returns @deferred.promise
        sinon.spy(@bunch, 'save')

    afterEach () ->
        @bunch.getRequest().save.restore()
        @bunch.getRequest().saveManyToManyRelations.restore()
        @bunch.getRequest().delete.restore()
        @bunch.save.restore()

    describe '#save', () ->
        it 'should save all models', () ->
            @bunch.save()
            @bunch.getRequest().save.calledWith(@bunch).should.be.ok

        it 'should save many-to-many relations', () ->
            @bunch.save()
            @bunch.getRequest().saveManyToManyRelations.calledWith(
              @bunch.config.parent, @bunch, @bunch.config.relation
            ).should.be.ok

    describe '#delete', () ->
        it 'should reset all models', () ->
            @bunch.delete()
            @bunch.models.length.should.be.equal 0

        it 'should call #save method', () ->
            @bunch.save()
            @bunch.save.called.should.be.ok
