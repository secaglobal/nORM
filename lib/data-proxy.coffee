class DataProxy
    constructor: (@_config) ->

    getConfig: () ->
        @_config

    createDataRequest: () ->
        throw new Exception 'Does not implemented'

module.exports = DataProxy