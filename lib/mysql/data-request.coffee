DBDataRequest = require '../db-data-request'
QueryBuilder = require './query-builder'

class MysqlDataRequest extends DBDataRequest
  find: (Model) ->
    query = new QueryBuilder()
      .setType(QueryBuilder.TYPE__SELECT)
      .setTable(Model.TABLE)
      .setFilters(@_filters or {})
      .setLimit(@_limit)
      .setOrder(@_order)
      .compose()

    @_proxy.perform(query)

module.exports = MysqlDataRequest;