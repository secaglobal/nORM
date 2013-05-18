Utils = require '../util'

class MysqlQueryBuilder
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

    constructor: (@_type = MysqlQueryBuilder.TYPE__SELECT) ->
        @

    setType: (@_type) ->
        @

    setTable: (@_table) ->
        @

    setFilters: (@_filters) ->
        @

    setFields: (@_fields) ->
        @

    setLimit: (@_limit) ->
        @

    setOrder: (@_order) ->
        @

    updateFields: (@_newValues) ->
        @_type = MysqlQueryBuilder.TYPE__UPDATE
        @

    insertValues: (@_insertValues) ->
        @_type = MysqlQueryBuilder.TYPE__INSERT
        @

    compose: () ->
        @["_compose#{@_type}"]()

    _composeSelect: () ->
        "select * from `#{@_table}`#{@_composeWhereClouse()}"

    _composeUpdate: () ->
        valuesRep = ("`#{n}`=#{MysqlQueryBuilder._escape(v)}" for n, v of @_newValues).join(',')

        "update `#{@_table}` set #{valuesRep}#{@_composeWhereClouse()}"

    _composeDelete: () ->
        "delete from `#{@_table}`#{@_composeWhereClouse()}"

    _composeInsert: () ->
        fields = (MysqlQueryBuilder._escapeField(field)for field in @_fields).join(',')
        values = (MysqlQueryBuilder._escape(set) for set in @_insertValues).join(',')
        "insert into `#{@_table}`(#{fields}) values#{values}"

    _composeWhereClouse: () ->
        whereClouse = ''
        whereClouse = (MysqlQueryBuilder._convertFilters @_filters) if @_filters
        whereClouse = " where #{whereClouse}" if whereClouse.length
        return whereClouse

    @_convertFilters: (filters) ->
        (@_convertFilter(filter,
          value) for filter, value of filters).join(' and ')

    @_convertFilter: (filter, value) ->
        isOperator = !!@_comparisonOperators[filter]
        # RETURN WITHOUT FILTER
        operator = if isOperator then @_comparisonOperators[filter] else '='

        if Utils.isHashMap(value)
            return "#{@_escapeField(filter)}#{@_convertFilters(value)}"

        filter = '' if isOperator
        operator = ' is ' if value is null

        return @_escapeField(filter) + operator + @_escape(value)

    @_escape: (value) ->
        #TODO prepare real escape
        _ = @
        if Utils.isArray(value)
            return '(' + value.map (v) ->
                _._escape v
            .join(',') + ')'
        else if value?
            return "'#{value.toString().replace(/\\/g, '\\\\').replace(/['"]/g, '\\\'')}'"
        else
            return 'null'

    @_escapeField: (field) ->
        field = field.replace /[^\w\.]/g, ''
        if not field.length or /\./.test field then field else "`#{field}`"

module.exports = MysqlQueryBuilder;