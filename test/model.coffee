#MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
#Schema = require "#{LIBS_PATH}/schema"
#VirtualSchema = require "#{LIBS_PATH}/virtual-schema"
#Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
#DataProvider = require "#{LIBS_PATH}/data-provider"

Person = require('./models')['Person']

describe '@Model', () ->
    beforeEach (done) ->
        self = @
        loadFixtures({
            Person: [
                {id: 1, name: 'Mike', age: 10, jobId: 1},
                {id: 2, name: 'Denis', age: 20, jobId: 2},
                {id: 3, name: 'Marge', age: 30, jobId: 3},
            ],
            Job: [
                {id: 1, title: 'Sales', salary: 100},
                {id: 2, title: 'Admin', salary: 200},
                {id: 3, title: 'Programmer', salary: 300},
            ],
            Task: [
                {id: 1, title: 'Draw template'},
                {id: 2, title: 'Conferences'},
                {id: 3, title: 'Prepare code'},
            ],
            Person__Task: [
                {id: 1, personId: 1, taskId: 1},
                {id: 2, personId: 1, taskId: 2},
                {id: 3, personId: 2, taskId: 1},
                {id: 4, personId: 3, taskId: 1},
                {id: 5, personId: 3, taskId: 3},
            ],
            Car: [
                {id: 1, title: 'BMW', personId: 1},
                {id: 2, title: 'Nissan', personId: 2},
                {id: 3, title: 'Toyota', personId: 3},
                {id: 4, title: 'Audi', personId: 2},
            ],
        })
        .then () ->
            self.persons = new Collection([], {model: Person})
            self.persons.load()
        .then(() -> done()).fail(done)

    describe 'Relations', () ->
        it 'should provide access to many-to-one relation', (done) ->
            persons = @persons
            persons.first().require('job')
                .then (person) ->
                    expect(persons.findWhere({id: 1}).job.id).be.equal 1
                    expect(persons.findWhere({id: 2}).job.id).be.equal 2
                    expect(persons.findWhere({id: 3}).job.id).be.equal 3

                    done()
                .fail(done)

        it 'should provide access to one-to-many relation', (done) ->
            persons = @persons
            persons.findWhere({id: 2}).require('cars')
                .then (person) ->
                    expect(person.cars.length).be.equal 2
                    expect(person.cars.findWhere(title: 'Nissan')).be.ok
                    expect(person.cars.findWhere(title: 'Audi')).be.ok
                    done()
                .fail(done)

        it 'should provide access to many-to-many relation', (done) ->
            persons = @persons
            persons.findWhere({name: 'Marge'}).require('tasks')
                .then (person) ->
                    expect(person.tasks.length).be.equal 2
                    expect(person.tasks.findWhere(title: 'Draw template')).be.ok
                    expect(person.tasks.findWhere(title: 'Prepare code')).be.ok
                    done()
                .fail(done)

        it 'should pull all requested relations', (done) ->
            persons = @persons
            persons.findWhere({name: 'Marge'}).require('cars','tasks','job')
                .then (person) ->
                    expect(person.tasks.length).be.equal 2
                    expect(person.cars.length).be.equal 1
                    expect(person.job.title).be.equal 'Programmer'

                    done()
                .fail(done)


