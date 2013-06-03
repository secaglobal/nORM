dataProvider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
MysqlDataRequest = require("#{LIBS_PATH}/mysql/data-request");
MysqlQueryBuilder = require("#{LIBS_PATH}/mysql/query-builder");
Model = require("#{LIBS_PATH}/model");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'

class FirstModel extends Model
    @TABLE: 'TargetTable'
    @PROXY_ALIAS: 'test1'

class TestModel extends Model
    @TABLE: 'TestTable'
    @PROXY_ALIAS: 'test2'

    @belongsTo 'relation1', use: FirstModel, myField: 'firstId'
    @hasMany 'relation2', use: FirstModel, theirField: 'testId'
    @hasAndBelongsToMany 'relation3', use: FirstModel

describe '@DBDataRequest', () ->
    assignPromise = () ->
        if not @proxy.perform.restore
            sinon.stub(@proxy, 'perform')

        _ = @
        @deferred = Q.defer()
        promise = @deferred.promise
        @proxy.perform.returns promise;
        promise.then () ->
            assignPromise.call _

    beforeEach () ->
        dataProvider.registerProxy('test1', new Proxy({test1: true}))
        dataProvider.registerProxy('test2', new Proxy({test2: true}))

        @proxy = dataProvider.getProxy TestModel
        @request = new MysqlDataRequest(@proxy)
        @queryBuilder = new MysqlQueryBuilder()

        @models = new Collection(
          [
              {id: 4, name: 'jako', age: 20, firstId: 1},
              {name: 'mona'},
              {name: 'mona2'},
              {name: 'mona3', age: 30},
              {id: 5, name: 'fill', firstId: 2}
              {id: 7, name: 'fifa', firstId: 5},
          ],
          {model: TestModel}
        ).models

        assignPromise.call @

    afterEach: () ->
        @proxy.perform.restore()

    describe '#find', () ->
        it 'should prepare query and execute via @DataProxy#query', () ->
            @request.setFilters({id: 4, state:
                {$ne: 5}}).find(TestModel)
            @proxy.perform.called.should.be.ok

        it 'should return promise', () ->
            expect(@request.find(TestModel)).to.be.instanceof Q.allResolved(
              []).constructor

    describe '#save', () ->
        it 'should perfotm save for all changed models', () ->
            updateQuery1 = @queryBuilder.setTable(TestModel.TABLE).updateFields({name: 'jako1'}).setFilters(id: 4).compose()
            updateQuery2 = @queryBuilder.setTable(TestModel.TABLE).updateFields({name: 'fifaEdited', age: 40}).setFilters(id: 7).compose()

            @models[0].set name: 'jako1'
            @models[5].set name: 'fifaEdited', age: 40

            @request.save @models

            @proxy.perform.calledWith(updateQuery1).should.be.ok
            @proxy.perform.calledWith(updateQuery2).should.be.ok


        it 'should perfotm save for all new models', () ->
            insertQuery1 = @queryBuilder.setTable(TestModel.TABLE).setFields(
              ['name']).insertValues([
                ['mona'],
                ['mona2']
            ]).compose()

            insertQuery2 = @queryBuilder.setTable(TestModel.TABLE).setFields(
              ['age', 'name']).insertValues([
                [30, 'mona3']
            ]).compose()

            @request.save @models, false

            @proxy.perform.calledWith(insertQuery1).should.be.ok
            @proxy.perform.calledWith(insertQuery2).should.be.ok

        it 'should set ids for new models', (done) ->
            _ = @
            @request.save(@models).then () ->
                try
                    col =  new Collection(_.models)
                    col.where({id: undefined}).length.should.be.equal 0
                    col.where({id: 142}).length.should.not.be.equal 0

                    done()
                catch e
                    done e

            @deferred.resolve({insertId: 142})

        it 'should return promise', () ->
            expect(@request.save @models).to.be.instanceof Q.allResolved(
              []).constructor

    describe '#delete', () ->
        it 'should perfotm delete for all models that have id', () ->
            deleteQuery = @queryBuilder.setType(MysqlQueryBuilder.TYPE__DELETE).setTable(TestModel.TABLE).setFilters({id:
                {$in: [4, 5, 7]}}).compose()

            @request.delete @models

            @proxy.perform.calledWith(deleteQuery).should.be.ok


        it 'should return promise', () ->
            @request.delete @models
            expect(@request.save @models).to.be.instanceof Q.defer().promise.constructor

    describe '#fillManyToOneRelation', () ->
        it 'should create query end execute it', () ->
            searchQuery = @queryBuilder.setTable(FirstModel.TABLE).setFilters({id:
                {$in: [1, 2, 5]}}).compose()

            @request.fillManyToOneRelation @models, 'relation1'
            @proxy.perform.calledWith(searchQuery).should.be.ok

        it 'should assign result to appropriate model', (done) ->
            _ = @

            @request.fillManyToOneRelation(@models, 'relation1').then () ->
                try
                    expect(_.models[0]._relationsCache.relation1).to.be.ok
                    expect(_.models[0]._relationsCache.relation1.first()).instanceof Model
                    _.models[0]._relationsCache.relation1.first().get('id').should.equal 1

                    expect(_.models[4]._relationsCache.relation1).to.be.ok
                    expect(_.models[4]._relationsCache.relation1.first()).instanceof Model
                    _.models[4]._relationsCache.relation1.first().get('id').should.equal 2

                    expect(_.models[5]._relationsCache.relation1).to.be.ok
                    expect(_.models[5]._relationsCache.relation1.isEmpty()).to.be.ok

                    done()
                catch err
                    done err

            @deferred.resolve [{id: 1}, {id: 2}]

        it 'should return promise', () ->
            res = @request.fillManyToOneRelation(@models, 'relation1')
            expect(res).to.be.instanceof Q.defer().promise.constructor

    describe '#fillOneToManyRelation', () ->
        it 'should create query end execute it', () ->
            searchQuery = @queryBuilder
                .setTable(FirstModel.TABLE)
                .setFilters({testId: {$in: [4, 5, 7]}})
                .compose()

            @request.fillOneToManyRelation @models, 'relation2'

            @proxy.perform.calledWith(searchQuery).should.be.ok

        it 'should assign result to appropriate model', (done) ->
            _ = @

            @request.fillOneToManyRelation(@models, 'relation2').then () ->
                try
                    expect(_.models[0]._relationsCache.relation2).to.be.ok
                    expect(_.models[0]._relationsCache.relation2.length).to.be.equal 1
                    _.models[0]._relationsCache.relation2.first().get('id').should.equal 1

                    expect(_.models[5]._relationsCache.relation2).to.be.ok
                    expect(_.models[5]._relationsCache.relation2.length).to.be.equal 2
                    _.models[5]._relationsCache.relation2.first().get('id').should.equal 2
                    _.models[5]._relationsCache.relation2.at(1).get('id').should.equal 3

                    expect(_.models[4]._relationsCache.relation2).to.be.ok
                    expect(_.models[4]._relationsCache.relation2.isEmpty()).to.be.ok

                    done()
                catch err
                    done err

            @deferred.resolve [
                {id: 1, testId: 4},
                {id: 2, testId: 7},
                {id: 3, testId: 7}
            ]

        it 'should return promise', () ->
            res = @request.fillOneToManyRelation(@models, 'relation2')
            expect(res).to.be.instanceof Q.defer().promise.constructor

    describe '#fillManyToManyRelation', () ->
        it 'should search in crosstable', () ->
            filters = {}
            filters[TestModel.TABLE] = {$in: [4, 5, 7]}
            searchQuery = @queryBuilder
                .setTable(FirstModel.TABLE + '__' + TestModel.TABLE)
                .setFilters(filters)
                .compose()

            @request.fillManyToManyRelation @models, 'relation3'

            @proxy.perform.calledWith(searchQuery).should.be.ok

        it 'should search in target table', (done) ->
            _ = @
            searchQuery = @queryBuilder
                .setTable(FirstModel.TABLE)
                .setFilters({id: {$in: [7, 8, 9, 10]}})
                .compose()

            @request.fillManyToManyRelation(@models, 'relation3')
                .then () ->
                    try
                        _.proxy.perform.calledWith(searchQuery).should.be.ok
                        done()
                    catch e
                        done(e)

            @deferred.promise.then () ->
                _.deferred.resolve [{id: 7}, {id: 8}, {id: 9}, {id: 10}]

            @deferred.resolve [
                {TestTable: 4, TargetTable: 7},
                {TestTable: 4, TargetTable: 8},
                {TestTable: 4, TargetTable: 9},
                {TestTable: 7, TargetTable: 10},
            ]

        it 'should return promise', () ->
            res = @request.fillManyToManyRelation(@models, 'relation3')
            expect(res).to.be.instanceof Q.defer().promise.constructor

        it 'should assign result to appropriate model', (done) ->
            _ = @

            @request.fillManyToManyRelation(@models, 'relation3').then () ->
                try
                    expect(_.models[0]._relationsCache.relation3).to.be.ok
                    expect(_.models[0]._relationsCache.relation3.length).to.be.equal 3
                    _.models[0]._relationsCache.relation3.first().get('id').should.equal 7
                    _.models[0]._relationsCache.relation3.at(1).get('id').should.equal 8
                    _.models[0]._relationsCache.relation3.at(2).get('id').should.equal 9

                    expect(_.models[5]._relationsCache.relation3).to.be.ok
                    expect(_.models[5]._relationsCache.relation3.length).to.be.equal 1
                    _.models[5]._relationsCache.relation3.first().get('id').should.equal 10

                    expect(_.models[4]._relationsCache.relation3).to.be.ok
                    expect(_.models[4]._relationsCache.relation3.isEmpty()).to.be.ok

                    done()
                catch err
                    done err

            @deferred.promise.then () ->
                _.deferred.resolve [{id: 7}, {id: 8}, {id: 9}, {id: 10}]

            @deferred.resolve [
                {TestTable: 4, TargetTable: 7},
                {TestTable: 4, TargetTable: 8},
                {TestTable: 4, TargetTable: 9},
                {TestTable: 7, TargetTable: 10},
            ]


