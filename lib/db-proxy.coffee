DataProxy = require('./data-proxy')

class DBProxy extends DataProxy
    constructor: (@_config) ->

    getReadConnection: () ->
        throw 'not implemented yet'

    getWriteConnection: () ->
        throw 'not implemented yet'

module.exports = DBProxy