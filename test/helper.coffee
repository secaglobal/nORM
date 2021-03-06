global.LIBS_PATH = "#{__dirname}/../lib"

dataProvider = require "#{LIBS_PATH}/data-provider"
MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
MysqlQueryBuilder = require "#{LIBS_PATH}/mysql/query-builder"
Q = require 'q'
chai = require 'chai'
_ = require 'underscore'

chai.should()
global.expect = chai.expect
global.sinon = require 'sinon'


dataProvider.registerProxy("default", new MysqlProxy(
    host      : 'localhost',
    user      : 'test',
    password  : '',
    database  : 'test_norm',
    charset   : 'utf8',
#    debug     : ['ComQueryPacket']
#    debug     : ['ComQueryPacket', 'RowDataPacket']
))

global.loadFixtures = (data) ->
    deferred = Q.defer()
    promises = []
    proxy = dataProvider.getProxy 'default'

    for table, records of data
        promises.push proxy.perform("truncate #{table}")

        if records.length
            fields = _.keys(records[0]).sort()
            rows = []

            for record in records
                row = []
                rows.push row

                for field in fields
                    row.push(record[field] or null)

            query = new MysqlQueryBuilder()
                    .setTable(table)
                    .setFields(fields)
                    .insertValues(rows)
                    .compose()

            promises.push proxy.perform(query)

    Q.allSettled(promises).then (results) ->
        results.forEach (result) ->
            if result.state isnt "fulfilled"
                deferred.reject result.reason
        deferred.resolve()

    return deferred.promise


#require('nodetime').profile({
#    accountKey: '5597448534f79fa6626fd6132cbc92e3d7cbad88',
#    appName: 'Node.js Application'
#});

