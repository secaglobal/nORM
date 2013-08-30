DataRequest = require("#{LIBS_PATH}/mysql/data-request");
MySQLQueryBuilder = require("#{LIBS_PATH}/mysql/query-builder");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
Model = require("#{LIBS_PATH}/model");
Q = require 'q'

describe '@Mysql.Proxy', () ->
    beforeEach () ->
        @proxy = new Proxy {}
        @readQueryStub = sinon.stub(@proxy.getReadConnection(), 'query')
        @writeQueryStub = sinon.stub(@proxy.getWriteConnection(), 'query')

    afterEach () ->
        @readQueryStub.restore()
        @writeQueryStub.restore()

    describe '#createDataRequest', () ->
        it 'should return appropriate #DataRequest instance', () ->
            @proxy.createDataRequest(Model).should.be.instanceof DataRequest

    describe '#perform', ()->
        it 'should execute mysql query', () ->
            query = 'select * from Test where id = 1'
            @proxy.perform query
            @readQueryStub.calledWith(query).should.be.ok

        it 'should execute mysql query builders', () ->
            builder = new MySQLQueryBuilder().setTable('Test').setFilters({id: 1})

            @proxy.perform builder
            @readQueryStub.calledWith(builder.compose()).should.be.ok

        it 'should use read connection for select queries', () ->
            query = 'select * from Test where id = 1'
            @proxy.perform query
            @readQueryStub.called.should.be.ok
            @writeQueryStub.called.should.not.be.ok

        it 'should use write connection for non-select queries', () ->
            @proxy.perform 'update Test set testState = 1 where id =0'
            @proxy.perform 'delete from Test where id =0'
            @proxy.perform 'insert into Test set testState = 1'

            @readQueryStub.called.should.not.be.ok
            @writeQueryStub.called.should.be.ok

        it 'should returns promise for interaction with result', () ->
            query = 'select * from Test where id = 1'
            expect(@proxy.perform(query)).to.be.instanceof Q.defer().promise.constructor

        it 'should request FOUND_ROWS request if META__TOTAL_COUNT flag available', (done) ->
            spy = @readQueryStub
            builder = new MySQLQueryBuilder().setTable('Test')
                .addMeta(MySQLQueryBuilder.META__TOTAL_COUNT)
                .setFilters({id: 1})

            @proxy.perform(builder).then () ->
                try
                    spy.calledWith('select FOUND_ROWS() total').should.be.ok
                    done()
                catch e
                    done e
            .fail(done)

            spy.args[0][1](null, [{name: 'Charly'}])
            spy.args[1][1](null, [{total: 4}])

        it 'should set rows.totalCount if TOTAL_COUNT meta flag available', (done) ->
            spy = @readQueryStub
            builder = new MySQLQueryBuilder().setTable('Test')
                .addMeta(MySQLQueryBuilder.META__TOTAL_COUNT)
                .setFilters({id: 1})

            @proxy.perform(builder).then (rows) ->
                try
                    expect(rows.total).be.equal 4
                    done()
                catch e
                    done e
            .fail(done)

            spy.args[0][1](null, [{name: 'Charly'}])
            spy.args[1][1](null, [{total: 4}])


    describe '#getReadConnection', () ->
        it 'should return read connection to mysql', () ->
            @proxy.getReadConnection().query.should.be.a 'function'

        it 'should return same connection if already created', () ->
            @proxy.getReadConnection().should.be.equal @proxy.getReadConnection()

    describe '#getWriteConnection', () ->
        it 'should return write connection to mysql', () ->
            @proxy.getWriteConnection().query.should.be.a 'function'

        it 'should return same connection if already created', () ->
            @proxy.getWriteConnection().should.be.equal @proxy.getWriteConnection()

