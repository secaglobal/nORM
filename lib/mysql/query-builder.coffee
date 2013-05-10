Utils = require '../util'

class QueryBuilder
  @TYPE__SELECT = 'Select'
  @TYPE__INSERT = 'Insert'
  @TYPE__UPDATE = 'Update'
  @TYPE__DELETE = 'Delete'

  @_comparisonOperators =
    $eq: '=',
    $ne: '!=',
    $gt: '>',
    $gte: '>=',
    $lt: '<',
    $lte: '<=',
    $in: ' in',
    $nin: ' not in',

  @_logicalOperators =
    $or: 'or',
    $and: 'and',
    $not: '!',
    $nor: ''

  constructor:(@_type) ->
    @

  setType: (@_type) ->
    @

  setTable: (@_table) ->
    @

  setFilters: (@_filters) ->
    @

  updateFields: (@_newValues) ->
    @

  insertRows: (@_insertFields, @_insertValues...) ->
    @

  compose: () ->
    @["_compose#{@_type}"]()

  _composeSelect: () ->
    "select * from `#{@_table}`#{@_composeWhereClouse()}"

  _composeUpdate: () ->
    valuesRep = ("`#{n}`=#{QueryBuilder._escape(v)}" for n, v of @_newValues).join(',')

    "update `#{@_table}` set #{valuesRep}#{@_composeWhereClouse()}"

  _composeDelete: () ->
    "delete from `#{@_table}`#{@_composeWhereClouse()}"

  _composeInsert: () ->
    fields = (QueryBuilder._escapeField(field)for field in @_insertFields).join(',')
    values = (QueryBuilder._escape(set) for set in @_insertValues).join(',')
    "insert into `#{@_table}`(#{fields}) values#{values}"

  _composeWhereClouse: () ->
    whereClouse = ''
    whereClouse = (QueryBuilder._convertFilters @_filters) if @_filters
    whereClouse = " where #{whereClouse}" if whereClouse.length
    return whereClouse

  @_convertFilters: (filters) ->
    (QueryBuilder._convertFilter(filter, value) for filter, value of filters).join(' and ')

  @_convertFilter: (filter, value) ->
    isOperator = !!@_comparisonOperators[filter] # RETURN WITHOUT FILTER
    operator = if isOperator then @_comparisonOperators[filter] else '='

    if Utils.isHashMap(value)
      return "#{QueryBuilder._escapeField(filter)}#{QueryBuilder._convertFilters(value)}"

    filter = '' if isOperator
    operator = ' is ' if value is null

    return QueryBuilder._escapeField(filter) + operator + QueryBuilder._escape(value)

  @_escape: (value) ->
    #TODO prepare real escape
    if Utils.isArray(value)
      return '(' + value.map (v) ->
        QueryBuilder._escape v
      .join(',') + ')'
    else if value?
      return "'#{value.toString().replace(/\\/g, '\\\\').replace(/['"]/g, '\\\'')}'"
    else
      return 'null'

  @_escapeField: (field) ->
    field = field.replace /[^\w\.]/g, ''
    if not field.length or /\./.test field then field else "`#{field}`"

module.exports = QueryBuilder;