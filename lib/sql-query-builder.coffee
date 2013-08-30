class SQLQueryBuilder
    @TYPE__SELECT = 'Select'
    @TYPE__INSERT = 'Insert'
    @TYPE__UPDATE = 'Update'
    @TYPE__DELETE = 'Delete'

    @META__NO_CACHE = 'SQL_NO_CACHE'
    @META__TOTAL_COUNT = 'SQL_CALC_FOUND_ROWS'

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
        $and: 'and'

module.exports = SQLQueryBuilder;