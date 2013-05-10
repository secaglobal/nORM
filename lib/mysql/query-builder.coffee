Utils = require '../util'

class QueryBuilder
  @TYPE__SELECT = 'Select'
  @TYPE__INSERT = 'Insert'
  @TYPE__UPDATE = 'Update'
  @TYPE__DELETE = 'Delete'

  @_operators =
    $eq: '=',
    $ne: '!=',
    $gt: '>',
    $gte: '>=',
    $lt: '<',
    $lte: '<=',
    $in: ' in',
    $nin: ' not in',

  @_connectors =
    $or: 'or',
    $and: 'and'

  constructor:(@type) ->
    @

  setType: (@type) ->
    @

  setTable: (@table) ->
    @

  setFilters: (@filters) ->
    @

  compose: () ->
    @["compose#{@type}"]()

  composeSelect: () ->
    whereClouse = ''
    whereClouse = (QueryBuilder._convertFilters @filters) if @filters
    whereClouse = " where #{whereClouse}" if whereClouse.length

    "select * from `#{@table}`#{whereClouse}"

  @_convertFilters: (filters) ->
    (QueryBuilder._convertFilter(filter, value) for filter, value of filters).join(' and ')

  @_convertFilter: (filter, value) ->
    isOperator = !!@_operators[filter] # RETURN WITHOUT FILTER
    operator = if isOperator then @_operators[filter] else '='

    #console.log filter, filter in QueryBuilder._operators

    if Utils.isHashMap(value)
      return "`#{filter}`#{QueryBuilder._convertFilters(value)}"

    filter = '' if isOperator
    filter = "`#{filter}`" if filter.length
    operator = ' is ' if value is null
    value = QueryBuilder._escape(value)

    return filter + operator + value

  @_escape: (value) ->
    #TODO prepare real escape
    if Utils.isArray(value)
      return '(' + value.map (v) ->
        QueryBuilder._escape v
      .join(',') + ')'
    else if value?
      return "'#{value.toString().replace(/\\/g, '\\\\').replace(/'/g, '\\\'')}'"
    else
      return 'null'

module.exports = QueryBuilder;