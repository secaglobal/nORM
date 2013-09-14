Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection");
SQLDataRequest = require("#{LIBS_PATH}/sql-data-request");
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
        sinon.stub(Collection.prototype, 'save').returns @deferred.promise
        sinon.stub(Collection.prototype, 'delete').returns @deferred.promise
        sinon.spy(Person.schema, 'validate')
        #sinon.spy(Model.prototype, 'deepSave')
        #sinon.spy(Collection.prototype, 'deepSave')

    afterEach () ->
        Collection.prototype.require.restore()
        Collection.prototype.save.restore()
        Collection.prototype.delete.restore()
        Person.schema.validate.restore();
        #Model.prototype.deepSave.restore()
        #Collection.prototype.deepSave.restore()

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

    describe '#validate', () ->
        it 'should validate model', () ->
            @stive.validate()
            expect(Person.schema.validate.called).be.ok
            expect(Person.schema.validate.args[0]).be.deep.equal [@stive, null, false]

        it 'should transmit parameter for recursive validation', () ->
            @stive.validate(true)
            expect(Person.schema.validate.called).be.ok
            expect(Person.schema.validate.args[0]).be.deep.equal [@stive, true, false]

        it 'should return `false` if has errors', () ->
            expect(new Person().validate()).be.not.ok

        it 'should return errors if available', () ->
            stive = new Person()
            res = stive.validate(errors = [])

            expect(errors.length).be.equal 1
            expect(errors[0].field).be.equal 'name'
            expect(errors[0].error.code).be.equal "VALIDATOR__ERROR__REQUIRE"

        it 'should return `true` if no errors', () ->
            expect(@stive.validate()).be.ok

        it 'should be possible to recursively validate', () ->
            person = new Person name: 'Rex', cars: [{id: 4}]

            expect(person.validate(errors = [], true)).be.equal false
            expect(errors.length).be.equal 1
            expect(errors[0].field).be.equal 'cars'

    describe '#save', () ->
        it 'should use collection for saving', () ->
            spy = Collection.prototype.save

            @stive.save();

            expect(spy.called).be.ok
            expect(spy.lastCall.thisValue.models).be.deep.equal [@stive]
            expect(spy.calledWith(false)).be.ok

        it 'should return itself as first argument', (done) ->
            stive = @stive
            stive.save()
                .then (model) ->
                    expect(model).to.be.equal stive
                    done()
                .fail done

            @deferred.resolve()

        it 'should return promise', () ->
            expect(@stive.save()).to.be.deep.instanceof @deferred.promise.constructor

        it 'should be possible to save recursively', () ->
            stive = new Person({});
            stive.save(true)
            expect(Collection.prototype.save.calledWith(true)).be.ok;

#    describe '#deepSave', () ->
#        beforeEach () ->
#
#            @_person = new Person
#                name: 'Rex',
#                job:
#                    id: 2,
#                    title: 'developer',
#                cars: [{id: 4, title: 'BMW'}]
#
#        it 'should use datarequest for saving', () ->
#            @_person.deepSave();
#            expect(SQLDataRequest.prototype.save.called).be.ok
#            expect(SQLDataRequest.prototype.save.calledWith(new Collection([@_person]))).be.ok
#
#        it 'should save recursively', () ->
#            @_person.deepSave()
#            expect(@_person.job.deepSave.calledWith null, false).be.ok
#            expect(@_person.cars.deepSave.calledWith null, false).be.ok
#
#        it 'should return itself as first argument', (done) ->
#            stive = @_person
#            stive.deepSave()
#                .then (model) ->
#                    expect(model).to.be.equal stive
#                    done()
#                .fail done
#
#            @deferred.resolve()
#
#        it 'should return promise', () ->
#            expect(@_person.deepSave()).to.be.deep.instanceof @deferred.promise.constructor
#
#        it 'should fail if validation has not been passed', (done) ->
#            stive = new Person name: 'Rex', job: {id: 2}, cars: [{id: 4}]
#
#            stive.deepSave()
#                .then (model) ->
#                    done('Expect to fail')
#                .fail (errors) ->
#                    expect(errors).isArray
#                    done()

    describe '#delete', () ->
        it 'should use datarequest for delition', () ->
            spy = Collection.prototype.delete

            @stive.delete();

            expect(spy.called).be.ok
            expect(spy.lastCall.thisValue.models).be.deep.equal [@stive]
            expect(spy.calledWith()).be.ok

        it 'should return promise', () ->
            expect(@stive.delete()).to.be.deep.instanceof @deferred.promise.constructor

        it 'should replace itself from collection', () ->
            col = new Collection([@stive, {name: 'Alex'}])
            @stive.delete();
            expect(col.length).be.equal 1
            expect(col.first().name).be.equal 'Alex'

