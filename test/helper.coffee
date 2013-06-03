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
  user      : 'root',
  password  : 'ramstein',
  database  : 'norm_test',
  charset   : 'utf8',
  #debug        : true
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

    Q.allResolved(promises).then (promises)->
        for promise in promises
            if not promise.isFulfilled()
                deferred.reject promise.valueOf().exception
                return

        deferred.resolve()
    return deferred.promise




