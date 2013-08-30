SQLDataRequest = require '../sql-data-request'
MysqlQueryBuilder = require './query-builder'

class MysqlDataRequest extends SQLDataRequest
    _builder: (table, type = MysqlQueryBuilder.TYPE__SELECT) ->
        new MysqlQueryBuilder(type).setTable(table)

module.exports = MysqlDataRequest;