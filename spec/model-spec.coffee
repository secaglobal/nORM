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
            expect(@stive.cars.at(0).title).be.equal 'BMW'
            expect(@stive.cars.at(1).title).be.equal 'Lada'

        it 'should save original values', () ->
            @stive.name = 'other name'
            expect(@stive.original.name).be.equal 'Stive'

    describe '#require', () ->
        it 'should pass fields to parent collection', () ->
            res = @stive.require 'cars', 'task,', 'job'

            expect(Collection.prototype.require.calledWith('cars', 'task,', 'job')).be.ok
            expect(res).be.equal @deferred.promise
