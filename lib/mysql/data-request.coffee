SQLDataRequest = require '../sql-data-request'
MysqlQueryBuilder = require './query-builder'

class MysqlDataRequest extends SQLDataRequest
    _builder: (table) ->
        new MysqlQueryBuilder().setTable(table)

module.exports = MysqlDataRequest;