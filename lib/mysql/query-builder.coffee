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
    whereClouse = (QueryBuilder.convertFilters @filters) if @filters
    whereClouse = " where #{whereClouse}" if whereClouse.length

    "select * from #{@table}#{whereClouse}"

  @convertFilters: (filters) ->
    (QueryBuilder.convertFilter(filter, value) for filter, value of filters).join(',')

  @convertFilter: (filter, value) ->
    isOperator = !!@_operators[filter] # WITHOUT FILTER
    operator = @_operators[filter] || '='

    #console.log filter, filter in QueryBuilder._operators

    if value? and typeof value is 'object'
      return "#{filter}#{QueryBuilder.convertFilters(value)}"

    filter = '' if isOperator
    operator = ' is ' if value is null
    value = QueryBuilder.escape(value)

    return filter + operator + value

  @escape: (value) ->
    #TODO prepare real escape
    if value?
      value = "'#{value.toString().replace(/\\/g, '\\\\').replace(/'/g, '\\\'')}'"
    else
      value = 'null'

module.exports = QueryBuilder;