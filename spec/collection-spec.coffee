MysqlProxy = require("#{LIBS_PATH}/mysql/proxy");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'
Person = require('./models')['Person']

dataProvider = require("#{LIBS_PATH}/data-provider")

describe '@Collection', () ->
    before () ->
        dataProvider.registerProxy('default', new MysqlProxy {})

    beforeEach () ->
        @collection = new Collection [], {
            model: Person,
            fields: ['id'],
            order: {id: -1},
            limit: 10,
            offset: 1,
            filters:
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
        sinon.stub(@collection.getRequest(), 'setFields').returns @collection.getRequest()
        sinon.stub(@collection.getRequest(), 'fillRelation').returns @deferred.promise
        sinon.spy(@collection.getRequest(), 'fillTotalCount')
        sinon.spy(Person.schema, 'validate')

    afterEach () ->
        @collection.getRequest().find.restore()
        @collection.getRequest().setLimit.restore()
        @collection.getRequest().setOffset.restore()
        @collection.getRequest().setOrder.restore()
        @collection.getRequest().setFilters.restore()
        @collection.getRequest().setFields.restore()
        @collection.getRequest().save.restore()
        @collection.getRequest().delete.restore()
        @collection.getRequest().fillRelation.restore()
        @collection.getRequest().fillTotalCount.restore()
        Person.schema.validate.restore();

    describe '#constructor', () ->
        it 'should recognize which parameters are models and config', () ->
            col1 = new Collection([{id: 4}], {model: Person})
            col2 = new Collection({model: Person}, [{id: 5}])
            col3 = new Collection({model: Person})

            expect(col1.models[0].id).be.equal 4
            expect(col1.config.model).be.equal Person
            expect(col2.models[0].id).be.equal 5
            expect(col2.config.model).be.equal Person
            expect(col3.models.length).be.equal 0
            expect(col3.config.model).be.equal Person

    describe '#reset', () ->
        it 'should reset models with new list', () ->
            @collection.reset [{name: 'A', age: 1}, {name: 'B', age: 2}]

            expect(@collection.first().name).be.equal 'A'
            expect(@collection.at(1).name).be.equal 'B'

        it 'should update length', () ->
            @collection.reset [{name: 'A', age: 1}, {name: 'B', age: 2}]

            expect(@collection.length).be.equal 2

        it 'should convert objects to models', () ->
            @collection.reset [{name: 'A', age: 1}, {name: 'B', age: 2}]

            expect(@collection.first()).be.instanceof Person
            expect(@collection.at(1)).be.instanceof Person

        it 'should set parent collection for model', () ->
            @collection.reset [{name: 'A', age: 1}, {name: 'B', age: 2}]

            expect(@collection.first().collection).be.equal @collection
            expect(@collection.at(1).collection).be.equal @collection

    describe '#load', () ->
        it 'should request rows via model proxy', () ->
            @collection.load()
            @collection.getRequest().find.called.should.be.ok
            @collection.getRequest().find.calledWith(Person).should.be.ok

        it 'should return promise', () ->
            expect(@collection.load()).to.be.deep.instanceof @deferred.promise.constructor

        it 'should fill collection with received models', (done) ->
            _this = @
            @collection.load().then ()->
                try
                    _this.collection.length.should.be.equal 1
                    done()
                catch err
                    done err

            @deferred.resolve([
                {id: 4}
            ])

        it 'should pass collection as first argument for resolved promise', (done) ->
            _this = @
            @collection.load().then (col)->
                try
                    _this.collection.should.be.equal col
                    done()
                catch err
                    done err

            @deferred.resolve([
                {id: 4}
            ])

        it 'should request all requested relations', (done) ->
            col = @collection
            spy = col.getRequest().fillRelation

            col.setFields('name','job', 'tasks.id').load().then ()->
                try
                    spy.calledWithExactly(col, 'job', []).should.be.ok
                    spy.calledWithExactly(col, 'tasks', ['id']).should.be.ok
                    done()
                catch err
                    done err

            @deferred.resolve([
                {id: 4}
            ])

        it 'should use required fields', ()->
            @collection.load()
            @collection.getRequest().setFields.called.should.be.ok
            expect(@collection.getRequest().setFields.args[0][0]).be.ok
            @collection.getRequest().setFields.calledWith(@collection.config.fields).should.be.ok

        it 'should use filters', ()->
            @collection.load()
            @collection.getRequest().setFilters.called.should.be.ok
            expect(@collection.getRequest().setFilters.args[0][0]).be.ok
            @collection.getRequest().setFilters.calledWith(@collection.config.filters).should.be.ok

        it 'should use limit', ()->
            @collection.load()
            @collection.getRequest().setLimit.called.should.be.ok
            expect(@collection.getRequest().setLimit.args[0][0]).be.ok
            @collection.getRequest().setLimit.calledWith(@collection.config.limit).should.be.ok

        it 'should use offset', ()->
            @collection.load()
            @collection.getRequest().setOffset.called.should.be.ok
            expect(@collection.getRequest().setOffset.args[0][0]).be.ok
            @collection.getRequest().setOffset.calledWith(@collection.config.offset).should.be.ok

        it 'should use order', ()->
            @collection.load()
            @collection.getRequest().setOrder.called.should.be.ok
            expect(@collection.getRequest().setOrder.args[0][0]).be.ok
            @collection.getRequest().setOrder.calledWith(@collection.config.order).should.be.ok

        it 'should call request#fillTotalCount if option `total` is true', () ->
            @collection.config.total = true
            @collection.load()
            @collection.getRequest().fillTotalCount.called.should.be.ok

        it 'should set `total` property if required', (done) ->
            col = @collection
            col.config.total = true
            col.load().then () ->
                try
                    expect(col.total).be.equal 10
                    done()
                catch e
                    done e
            .fail(done)

            res = [{id: 4}]
            res.total = 10
            @deferred.resolve res

        it 'should set `total` property if required and total is zero', (done) ->
            col = @collection
            col.config.total = true
            col.load().then () ->
                try
                    expect(col.total).be.equal 0
                    done()
                catch e
                    done e
            .fail(done)

            res = []
            res.total = 0
            @deferred.resolve res

    describe '#save', () ->
        it 'should pass all models to @DataRequest#save', () ->
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            @collection.save()

            @collection.getRequest().save.calledWith(@collection).should.be.ok

        it 'should return promise', () ->
            expect(@collection.save()).to.be.deep.instanceof @deferred.promise.constructor

        it 'should throw exception if validation has not been passed', () ->
            col = @collection.reset [
                {id: 1, name: 'lego'} ,
                {}
            ]

            expect(() -> col.save()).to.throw()
            @collection.getRequest().save.called.should.be.not.ok

    describe '#delete', () ->
        it 'should pass all models to @DataRequest#delete', () ->
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            @collection.delete()

            @collection.getRequest().delete.calledWith(@collection).should.be.ok

        it 'should return promise', () ->
            expect(@collection.delete()).to.be.instanceof @deferred.promise.constructor

        it 'should reset models array if success', (done) ->
            _this = @
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]

            @collection.delete().then(() ->
                try
                    _this.collection.models.should.be.deep.equal []
                    done()
                catch err
                    done err
            )

            @deferred.resolve(123)

        it 'should keep models array if false', (done) ->
            _this = @
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]
            models = @collection.models

            @collection.delete().then null, (err) ->
                try
                    _this.collection.models.should.be.deep.equal models
                    done()
                catch err
                    done err

            @deferred.reject('something happen')

    describe '#require', () ->
        it 'should load relations via data-request', () ->
            @collection.require('job', 'tasks')
            expect(@collection.getRequest().fillRelation.called).to.be.ok
            expect(@collection.getRequest().fillRelation.calledWith @collection, 'job', []).to.be.ok
            expect(@collection.getRequest().fillRelation.calledWith @collection, 'tasks', []).to.be.ok

        it 'should returns promise', () ->
            expect(@collection.require('job', 'tasks')).to.be.instanceof  @deferred.promise.constructor

        it 'should pass collection as first parameter of promise', (done) ->
            col = @collection
            col.require('job', 'tasks').then (res) ->
                expect(res).be.equal col
                done()
            .fail(done)

            @deferred.resolve()

    describe '#toJSON', () ->
        it 'should return models', () ->
            @collection.reset [
                {id: 1, name: 'lego'} ,
                {name: 'mike'}
            ]

            expect(@collection.toJSON()).to.be.equal @collection.models

    describe  '#setFields', () ->
        it 'should be able to receive list of fields as array', () ->
            @collection.setFields ['id', 'name']
            expect(@collection.config.fields).be.deep.equal ['id', 'name']

        it 'should be able to receive list of fields as arguents', () ->
            @collection.setFields 'id', 'name'
            expect(@collection.config.fields).be.deep.equal ['id', 'name']

        it 'should separate model fields and relations fields', () ->
            @collection.setFields 'id', 'name', 'job', 'tasks.title'
            expect(@collection.config.fields).be.deep.equal ['id', 'name']
            expect(@collection.config.relations).be.deep.equal
                job : [],
                tasks : ['title']

    describe '#validete', () ->
        it 'should validate models', () ->
            @collection.reset([{name: 'Phil'}, {name: 'Rex'}]).validate()
            expect(Person.schema.validate.called).be.ok;
            expect(Person.schema.validate.args.length).be.equal @collection.length
            expect(Person.schema.validate.args[1]).be.deep.equal [@collection.at(1), null];

        it 'should return `false` if no errors', () ->
            expect(@collection.reset([{name: 'Phil'}, {}]).validate()).be.not.ok

        it 'should fill errors if available', () ->
            @collection.reset([{name: 'Phil'}, {}]).validate(errors = {})

            expect(errors[1][0].field).be.equal 'name'
            expect(errors[1][0].error.code).be.equal "VALIDATOR__ERROR__REQUIRE"

        it 'should return `true` if no errors', () ->
            expect(@collection.reset([{name: 'Phil'}, {name: 'Rex'}]).validate()).be.equal true

    describe '#remove', () ->
        it 'should remove model from collection', () ->
            @collection.reset([{name: 'Phil'}, {name: 'Rex'}])
            @collection.remove(@collection.findWhere(name: 'Phil'))
            expect(@collection.length).be.equal 1
            expect(@collection.first().name).be.equal 'Rex'



