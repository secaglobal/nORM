Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'
Person = require('./models')['Person']

describe '@Model', () ->
    beforeEach () ->
        @stive = new Person
            name: 'Stive',
            age: 18,
            job: {title: 'admin'},
            cars: [{title: 'BMW'}, {title: 'Lada'}]

        @deferred = Q.defer()

        sinon.stub(Collection.prototype, 'require').returns @deferred.promise

    afterEach () ->
        Collection.prototype.require.restore()

    describe '#constructor', () ->
        it 'should provide access to first level fields', () ->
            expect(@stive.name).be.equal 'Stive'
            expect(@stive.age).be.equal 18

        it 'should provide access to many-to-one relation', () ->
            expect(@stive.job).instanceof Model
            expect(@stive.job.title).be.equal 'admin'

        it 'should provide access to other relations', () ->
            expect(@stive.cars).instanceof Collection
            expect(@stive.cars.at(0).title).be.equal 'BMW'
            expect(@stive.cars.at(1).title).be.equal 'Lada'

        it 'should save original values', () ->
            @stive.name = 'other name'
            expect(@stive.original.name).be.equal 'Stive'

    describe '#require', () ->
        it 'should pass fields to parent collection', () ->
            res = @stive.require 'cars', 'task,', 'job'

            expect(Collection.prototype.require.calledWith('cars', 'task,', 'job')).be.ok
            expect(res).be.instanceof @deferred.promise.constructor

        it 'should provide model as first element of callback', (done) ->
            stive = @stive
            res = stive.require('cars', 'task,', 'job')
                .then (model) ->
                    try
                        expect(model).be.equal stive
                        done()
                    catch e
                        done e
                .fail (done)

            @deferred.resolve()


    describe '#getChangedAttributes', () ->
        it 'should return false if nothing was changed', () ->
            person = new Person({id: 4, name: 'name'});
            expect(person.getChangedAttributes()).is.not.ok

        it 'should return changed values', () ->
            person = new Person({id: 4, name: 'name', age: 12});
            person.name = 'other name'
            person.age = 14
            expect(person.getChangedAttributes()).is.deep.equal {name: 'other name', age: 14}

        it 'should ignore relations', () ->
            person = new Person({id: 4, name: 'name', job: {title: 'sometitle'}});
            person.job.title = "other title"
            expect(person.getChangedAttributes()).is.not.ok
            expect(person.job.getChangedAttributes()).is.deep.equal {title: 'other title'}


    describe '#hasChanges', () ->
        it 'should return false if nothing was changed', () ->
            person = new Person({id: 4, name: 'name'});
            expect(person.hasChanges()).is.not.ok

        it 'should return true if attributes were changed', () ->
            person = new Person({id: 4, name: 'name', age: 12});
            person.name = 'other name'
            person.age = 14
            expect(person.hasChanges()).is.ok

        it 'should ignore relations', () ->
            person = new Person({id: 4, name: 'name', job: {title: 'sometitle'}});
            person.job.title = "other title"
            expect(person.hasChanges()).is.not.ok
            expect(person.job.hasChanges()).is.ok

    describe '#toJSON', () ->
        it 'should insert all fields from schema', () ->
            person = new Person({id: 4, name: 'name', hasCar: true, _private: true})
            expect(person.toJSON()).to.be.deep.equal {id:4, name:"name"}