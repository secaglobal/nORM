MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection/collection"
SlaveCollection = require "#{LIBS_PATH}/collection/slave-collection"
DataProvider = require "#{LIBS_PATH}/data-provider"

Person = require('./../models')['Person']
Car = require('./../models')['Car']

describe '@Collection', () ->

    beforeEach (done) ->
        loadFixtures({
            Person: [
                {id: 1, name: 'Mike', age: 10},
                {id: 2, name: 'Denis', age: 20},
                {id: 3, name: 'Marge', age: 30},
            ],

            Car: [
                {id: 1, title: 'BMW', personId: 1},
                {id: 2, title: 'Nissan', personId: 2},
                {id: 3, title: 'Toyota', personId: 3},
                {id: 4, title: 'Audi', personId: 2},
            ]
        }).then(() -> done()).fail(done)

    describe '#save', () ->
        it 'should delete needless objects', (done) ->
            new Collection({model: Person, fields:['cars'], filters: {id: 2}, limit: 1}).load()
                .then (col) ->
                    col.first().cars.remove col.first().cars.models[0]
                    col.save(true)
                .then () ->
                    new Collection({model: Car}).load()
                .then (cars) ->
                    myCars = cars.where(personId: 2)
                    expect(myCars.length).be.equal 1
                    expect(myCars[0].id).be.equal 4
                    expect(cars.findWhere(personId: 1)).be.ok
                    expect(cars.findWhere(personId: 3)).be.ok
                    done()
                .fail done

        it 'should delete needless objects if objects received in request', (done) ->
            new Collection({model: Person, fields:['cars'], filters: {id: 2}, limit: 1}).load()
                .then (col) ->
                        model = col.first().toJSON()
                        model.cars = new SlaveCollection(model: Car, model.cars.map (m) -> m.toJSON())
                        new Collection [model], model: Person
                .then (col) ->
                        col.first().cars.remove col.first().cars.models[0]
                        col.save(true)
                .then () ->
                        new Collection({model: Car}).load()
                .then (cars) ->
                        myCars = cars.where(personId: 2)
                        expect(myCars.length).be.equal 1
                        expect(myCars[0].id).be.equal 4
                        expect(cars.findWhere(personId: 1)).be.ok
                        expect(cars.findWhere(personId: 3)).be.ok
                        done()
                .fail done





