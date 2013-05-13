DBProxy = require '../db-proxy'
DataRequest = require './data-request'
Mysql = require 'mysql'

class MysqlProxy extends DBProxy
  _readConnections: []

  createDataRequest: () ->
    new DataRequest(this)

  perform: (query)->
    ""

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