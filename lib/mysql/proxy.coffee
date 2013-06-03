DBProxy = require '../db-proxy'
DataRequest = require './data-request'
Mysql = require 'mysql'
Q = require 'q'

class MysqlProxy extends DBProxy
    _readConnections: []

    createDataRequest: () ->
        new DataRequest(this)

    perform: (query)->
        deferred = Q.defer()
        conn = @getReadConnection() if /^\s*select/.test query
        conn = @getWriteConnection() if not conn?

        conn.query query, (err, result) ->
            if err then deferred.reject(err) else deferred.resolve(result)

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