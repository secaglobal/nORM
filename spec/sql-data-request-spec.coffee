dataProvider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
MysqlDataRequest = require("#{LIBS_PATH}/mysql/data-request");
MysqlQueryBuilder = require("#{LIBS_PATH}/mysql/query-builder");
Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection/collection");
Q = require 'q'

models = require('./models')
Person = models.Person
Job = models.Job
Car = models.Car
Task = models.Task

describe '@SQLDataRequest', () ->
    assignPromise = () ->
        if not Proxy.prototype.perform.restore
            sinon.stub(Proxy.prototype, 'perform')

        _this = @
        @deferred = Q.defer()
        promise = @deferred.promise
        Proxy.prototype.perform.returns promise;
        promise.then () ->
            assignPromise.call _this

    beforeEach () ->
        @proxy = dataProvider.getProxy(Person)
        @request = new MysqlDataRequest(@proxy)
        @queryBuilder = new MysqlQueryBuilder()

        @people = new Collection(
          [
              {id: 4, name: 'jako', age: 20, jobId: 1},
              {name: 'mona'},
              {name: 'mona2'},
              {name: 'mona3', age: 30},
              {id: 5, name: 'fill', jobId: 2}
              {id: 7, name: 'fifa', jobId: 5},
          ],
          {model: Person}
        )

        @models = @people.models
        @people.setModelsSyncedWithDB()

        @tasks = new Collection([
            {id: 12, title: 'Copy paper'}
            {id: 24, title: 'Clean rubbish'}
            {id: 37, title: 'Switch off light'}
        ], {model: Task})

        assignPromise.call @

    afterEach () ->
        @proxy.perform.restore()

    describe '#find', () ->
        it 'should prepare query or builder and execute via @DataProxy#query', () ->
            query = @queryBuilder
                .setTable(Person.schema.name)
                .setFilters(id: 4, state: {$ne: 5})
                .compose()

            @request.setFilters({id: 4, state: {$ne: 5}}).find(Person)
            expect(@proxy.perform.args[0]).be.ok
            expect(@proxy.perform.args[0][0].compose()).be.equal query

        it 'should return promise', () ->
            expect(@request.find(Person)).to.be.instanceof Q.allSettled(
              []).constructor

        it 'should set meta tag META__TOTAL_COUNT if required', () ->
            @request.setFilters({id: 4, state: {$ne: 5}}).fillTotalCount().find(Person)
            builder = @proxy.perform.args[0][0]
            expect(builder.hasMeta(MysqlQueryBuilder.META__TOTAL_COUNT)).be.ok



    describe '#save', () ->
        it 'should perfotm save for all changed models', () ->
            updateQuery1 = @queryBuilder.setTable(Person.schema.name).updateFields({name: 'jako1'}).setFilters(id: 4).compose()
            updateQuery2 = @queryBuilder.setTable(Person.schema.name).updateFields({name: 'fifaEdited', age: 40}).setFilters(id: 7).compose()

            @models[0].name = 'jako1'
            @models[5].name = 'fifaEdited'
            @models[5].age = 40

            @request.save @people

            @proxy.perform.calledWith(updateQuery1).should.be.ok
            @proxy.perform.calledWith(updateQuery2).should.be.ok

        it 'should perfotm save for all new models', () ->
            insertQuery1 = @queryBuilder.setTable(Person.schema.name).setFields(
                ['name']).insertValues([
                    ['mona'],
                    ['mona2']
            ]).compose()

            insertQuery2 = @queryBuilder.setTable(Person.schema.name).setFields(
              ['age', 'name']).insertValues([
                [30, 'mona3']
            ]).compose()

            @request.save @people, false

            @proxy.perform.calledWith(insertQuery1).should.be.ok
            @proxy.perform.calledWith(insertQuery2).should.be.ok

        it 'should set ids for new models', (done) ->
            self = @
            @request.save(@people).then () ->
                try
                    col =  new Collection(self.models, {model: Person})
                    col.where {id: undefined}
                    col.where({id: undefined}).length.should.be.equal 0
                    col.where({id: 142}).length.should.not.be.equal 0

                    done()
                catch e
                    done e
            .fail done

            @deferred.resolve({insertId: 142})


        it 'should return promise', () ->
            expect(@request.save @people).to.be.instanceof Q.allSettled(
              []).constructor

        it 'should perfotm save for all models that not synced with db', () ->
            @people.setModelsSyncedWithDB(false)

            updateQuery1 = @queryBuilder.setTable(Person.schema.name)
                .updateFields({id: 4, name: 'jako', 'age': 20, jobId: 1})
                .setFilters(id: 4)
                .compose()

            @request.save @people
            
            @proxy.perform.calledWith(updateQuery1).should.be.ok

    describe '#delete', () ->
        it 'should perfotm delete for all models that have id', () ->
            deleteQuery = @queryBuilder
                            .setType(MysqlQueryBuilder.TYPE__DELETE)
                            .setTable(Person.schema.name)
                            .setFilters({id: {$in: [4, 5, 7]}})
                            .compose()

            @request.delete @people

            @proxy.perform.calledWith(deleteQuery).should.be.ok


        it 'should return promise', () ->
            expect(@request.delete @people).to.be.instanceof Q.defer().promise.constructor


    describe '#fillManyToOneRelation', () ->
        it 'should create query end execute it', () ->
            searchQuery = @queryBuilder
                            .setTable(Job.schema.name)
                            .setFilters({id: {$in: [1, 2, 5]}})
                            .compose()

            @request.fillManyToOneRelation @people, 'job'

            @proxy.perform.called.should.be.ok
            @proxy.perform.args[0][0].compose().should.be.equal searchQuery

        it 'should assign result to appropriate model', (done) ->
            _this = @

            @request.fillManyToOneRelation(@people, 'job').then () ->
                expect(_this.models[0].job).to.be.ok
                expect(_this.models[0].job).instanceof Model
                _this.models[0].job.id.should.equal 1

                expect(_this.models[4].job).to.be.ok
                expect(_this.models[4].job).instanceof Model
                _this.models[4].job.id.should.equal 2

                expect(_this.models[5].job).to.be.not.ok

                done()
            .fail(done)

            @deferred.resolve [{id: 1}, {id: 2}]

        it 'should return promise', () ->
            res = @request.fillManyToOneRelation(@people, 'job')
            expect(res).to.be.instanceof Q.defer().promise.constructor

        it 'should set required fields', () ->
            searchQuery = @queryBuilder
                .setTable(Job.schema.name)
                .setFields('id', 'title')
                .setFilters({id: {$in: [1, 2, 5]}})
                .compose()

            @request.fillManyToOneRelation @people, 'job', ['id', 'title']

            @proxy.perform.called.should.be.ok
            @proxy.perform.args[0][0].compose().should.be.equal searchQuery

    describe '#fillOneToManyRelation', () ->
        it 'should create query end execute it', () ->
            searchQuery = @queryBuilder
                .setTable(Car.schema.name)
                .setFilters({personId: {$in: [4, 5, 7]}})
                .compose()

            @request.fillOneToManyRelation @people, 'cars'

            @proxy.perform.called.should.be.ok
            @proxy.perform.args[0][0].compose().should.be.equal searchQuery

        it 'should assign result to appropriate model', (done) ->
            _this = @

            @request.fillOneToManyRelation(@people, 'cars').then () ->
                try
                    expect(_this.models[0].cars).to.be.ok
                    expect(_this.models[0].cars.length).to.be.equal 1
                    _this.models[0].cars.first().id.should.equal 1

                    expect(_this.models[5].cars).to.be.ok
                    expect(_this.models[5].cars.length).to.be.equal 2
                    _this.models[5].cars.first().id.should.equal 2
                    _this.models[5].cars.at(1).id.should.equal 3

                    expect(_this.models[4].cars).to.be.ok
                    expect(_this.models[4].cars.isEmpty()).to.be.ok

                    done()
                catch err
                    done err

            @deferred.resolve [
                {id: 1, personId: 4},
                {id: 2, personId: 7},
                {id: 3, personId: 7}
            ]

        it 'should return promise', () ->
            res = @request.fillOneToManyRelation(@people, 'cars')
            expect(res).to.be.instanceof Q.defer().promise.constructor

        it 'should set required fields', () ->
            searchQuery = @queryBuilder
                .setTable(Car.schema.name)
                .setFields('id', 'title')
                .setFilters({personId: {$in: [4, 5, 7]}})
                .compose()

            @request.fillOneToManyRelation @people, 'cars', ['id', 'title']

            @proxy.perform.called.should.be.ok
            @proxy.perform.args[0][0].compose().should.be.equal searchQuery

    describe '#fillManyToManyRelation', () ->
        it 'should search in crosstable', () ->
            filters = {}
            filters[Person.schema.defaultFieldName] = {$in: [4, 5, 7]}
            searchQuery = @queryBuilder
                .setTable(Person.schema.name + '__' + Task.schema.name)
                .setFilters(filters)
                .compose()

            @request.fillManyToManyRelation @people, 'tasks'
            @proxy.perform.calledWith(searchQuery).should.be.ok

        it 'should search in target table', (done) ->
            _this = @
            searchQuery = @queryBuilder
                .setTable(Task.schema.name)
                .setFilters({id: {$in: [7, 8, 9, 10]}})
                .compose()

            @request.fillManyToManyRelation(@people, 'tasks')
                .then () ->
                    try
                        _this.proxy.perform.args[1][0].compose().should.be.equal searchQuery
                        done()
                    catch e
                        done(e)
                .fail done

            @deferred.promise.then () ->
                _this.deferred.resolve [{id: 7}, {id: 8}, {id: 9}, {id: 10}]

            @deferred.resolve [
                {personId: 4, taskId: 7},
                {personId: 4, taskId: 8},
                {personId: 4, taskId: 9},
                {personId: 7, taskId: 10},
            ]

        it 'should return promise', () ->
            res = @request.fillManyToManyRelation(@people, 'tasks')
            expect(res).to.be.instanceof Q.defer().promise.constructor

        it 'should assign result to appropriate model', (done) ->
            _this = @

            @request.fillManyToManyRelation(@people, 'tasks').then () ->
                try
                    expect(_this.models[0].tasks).to.be.ok
                    expect(_this.models[0].tasks.length).to.be.equal 3
                    _this.models[0].tasks.first().id.should.equal 7
                    _this.models[0].tasks.at(1).id.should.equal 8
                    _this.models[0].tasks.at(2).id.should.equal 9

                    expect(_this.models[5].tasks).to.be.ok
                    expect(_this.models[5].tasks.length).to.be.equal 1
                    _this.models[5].tasks.first().id.should.equal 10

                    expect(_this.models[4].tasks).to.be.ok
                    expect(_this.models[4].tasks.isEmpty()).to.be.ok

                    done()
                catch err
                    done err

            @deferred.promise.then () ->
                _this.deferred.resolve [{id: 7}, {id: 8}, {id: 9}, {id: 10}]

            @deferred.resolve [
                {personId: 4, taskId: 7},
                {personId: 4, taskId: 8},
                {personId: 4, taskId: 9},
                {personId: 7, taskId: 10},
            ]

        it 'should set required fields', (done) ->
            _this = @
            searchQuery = @queryBuilder
                .setTable(Task.schema.name)
                .setFields('id', 'title')
                .setFilters({id: {$in: [7, 8, 9, 10]}})
                .compose()

            @request.fillManyToManyRelation(@people, 'tasks', ['id', 'title'])
                .then () ->
                    _this.proxy.perform.args[1][0].compose().should.be.equal searchQuery
                    done()
                .fail done

            @deferred.promise.then () ->
                _this.deferred.resolve [{id: 7}, {id: 8}, {id: 9}, {id: 10}]

            @deferred.resolve [
                {personId: 4, taskId: 7},
                {personId: 4, taskId: 8},
                {personId: 4, taskId: 9},
                {personId: 7, taskId: 10},
            ]

    describe '#saveManyToManyRelations', () ->
        it 'should delete all relations except available', () ->
            query = new MysqlQueryBuilder(MysqlQueryBuilder.TYPE__DELETE)
                .setTable('Person__Task')
                .setFilters({personId: @models[0].id, taskId: {$nin: [12,24,37]}})
                .compose()

            @request.saveManyToManyRelations(@models[0], @tasks, 'tasks')

            expect(@proxy.perform.args[0][0].compose()).be.equal query

        it 'should delete all relations if nothing should be added', () ->
            tasks = new Collection([], {model: Task})
            query = new MysqlQueryBuilder(MysqlQueryBuilder.TYPE__DELETE)
                .setTable('Person__Task')
                .setFilters({personId: @models[0].id})
                .compose()

            @request.saveManyToManyRelations(@models[0], tasks, 'tasks')

            expect(@proxy.perform.args[0][0].compose()).be.equal query

        it 'should save relations', (done) ->
            _this = @
            parentId = @models[0].id
            query = new MysqlQueryBuilder(MysqlQueryBuilder.TYPE__INSERT)
                .setTable('Person__Task')
                .setFields(['personId', 'taskId'])
                .insertValues([[parentId, 12], [parentId, 24], [parentId, 37]])
                .compose()

            @request.saveManyToManyRelations(@models[0], @tasks, 'tasks').then () ->
                expect(_this.proxy.perform.args[1][0].compose()).be.equal query
                done()
            .fail(done)

            @deferred.promise.then () ->
                _this.deferred.resolve()
            @deferred.resolve()

        it 'should just delete all relations if received empty collection', (done) ->
            _this = @
            tasks = new Collection([], {model: Task})
            @request.saveManyToManyRelations(@models[0], tasks, 'tasks').then () ->
                expect(_this.proxy.perform.calledOnce).be.ok
                done()
            .fail(done)

            @deferred.promise.then () ->
                _this.deferred.resolve()
            @deferred.resolve()

        it 'should return promise', () ->
            res = @request.saveManyToManyRelations(@models[0], @tasks, 'tasks')
            expect(res).to.be.instanceof Q.defer().promise.constructor

