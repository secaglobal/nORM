DBDataRequest = require '../db-data-request'
QueryBuilder = require './query-builder'

class MysqlDataRequest extends DBDataRequest
    _builder: (table) ->
        new QueryBuilder().setTable(table)

module.exports = MysqlDataRequest;