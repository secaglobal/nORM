class DataRequest
    constructor: (@_proxy) ->

    getProxy: () ->
        @_proxy

    setFilters: (@_filters) ->
        @

    setLimit: (@_limit) ->
        @

    setOffset: (@_offset) ->
        @

    setOrder: (@_order) ->
        @

    find: (model) ->
        throw 'Absract method'

    save: (models) ->
        throw 'Absract method'

    delete: (models) ->
        throw 'Absract method'


module.exports = DataRequest;