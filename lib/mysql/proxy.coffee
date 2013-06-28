SQLProxy = require '../sql-proxy'
MySQLQueryBuilder = require './query-builder'
DataRequest = require './data-request'
Mysql = require 'mysql'
Q = require 'q'
_ = require 'underscore'

class MysqlProxy extends SQLProxy
    _readConnections: []

    createDataRequest: () ->
        new DataRequest(this)

    perform: (query)->
        if query instanceof MySQLQueryBuilder
            builder = query
            query = builder.compose()
            fillTotalCount = builder.hasMeta MySQLQueryBuilder.META__TOTAL_COUNT

        deferred = Q.defer()
        conn = @getReadConnection() if /^\s*select/.test query
        conn = @getWriteConnection() if not conn?

        conn.query query, (err, result) ->
            if err
                deferred.reject(err)
            else if fillTotalCount
                conn.query 'select FOUND_ROWS() total', (err, countResult) ->
                    if err
                        deferred.reject(err)
                    else
                        result.total = countResult[0].total
                        deferred.resolve(result)
            else
                deferred.resolve(result)

        deferred.promise

    getReadConnection: () ->
        if not @_readConnections[0]?
            @_readConnections[0] = @_createConnection()
        @_readConnections[0]

    getWriteConnection: () ->
        if not @_writeConnection?
            @_writeConnection = @_createConnection()
        @_writeConnection

    _createConnection: () ->
        Mysql.createConnection(@_config)

module.exports = MysqlProxy