DataRequest = require("#{LIBS_PATH}/data-request");
Collection = require("#{LIBS_PATH}/collection");
Q = require 'q'

models = require('./models')
Person = models.Person
Job = models.Job
Car = models.Car
Task = models.Task

describe '@DataRequest', () ->
    beforeEach () ->
        @deferred = Q.defer()
        @request = new DataRequest()
        @models = new Collection(
            [
                {id: 4, name: 'jako', age: 20, jobId: 1},
                {name: 'mona'},
                {name: 'mona2'},
                {name: 'mona3', age: 30},
                {id: 5, name: 'fill', jobId: 2}
                {id: 7, name: 'fifa', jobId: 5},
            ],
            {model: Person}
        ).models

        sinon.stub(@request, 'fillOneToManyRelation').returns @deferred.promise
        sinon.stub(@request, 'fillManyToOneRelation').returns @deferred.promise
        sinon.stub(@request, 'fillManyToManyRelation').returns @deferred.promise

    afterEach () ->
        @request.fillOneToManyRelation.restore()
        @request.fillManyToOneRelation.restore()
        @request.fillManyToManyRelation.restore()

    describe '#fillRelation', () ->

        it 'should recognize many-to-one relation and use #fillManyToOneRelation', () ->
            @request.fillRelation @models, 'job'
            @request.fillManyToOneRelation.calledWith(@models, 'job').should.be.ok

        it 'should recognize one-to-many relation and use #fillOneToManyRelation', () ->
            @request.fillRelation @models, 'cars'
            @request.fillOneToManyRelation.calledWith(@models, 'cars').should.be.ok

        it 'should recognize many-to-many relation and use #fillManyToManyRelation', () ->
            @request.fillRelation @models, 'tasks'
            @request.fillManyToManyRelation.calledWith(@models, 'tasks').should.be.ok

        it 'should recognize virtual one-to-many relation and use #fillVirtualOneToManyRelation'
        it 'should recognize virtual one-to-one relation and use #fillVirtualOneToOneRelation'

        it 'should return promise', () ->
            res = @request.fillRelation @models, 'job'
            expect(res).to.be.instanceof Q.defer().promise.constructor

        it 'should do not process relations if models list is empty', () ->
            @request.fillRelation [], 'job'
            @request.fillOneToManyRelation.called.should.be.not.ok
            @request.fillManyToOneRelation.called.should.be.not.ok
            @request.fillManyToManyRelation.called.should.be.not.ok

        it 'should return resolved promise if models is empty', () ->
            res = @request.fillRelation [], 'job'
            expect(res).to.be.instanceof Q.defer().promise.constructor
            res.isFulfilled().should.be.ok


