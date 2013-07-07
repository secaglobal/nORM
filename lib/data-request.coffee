Q = require 'q'

class DataRequest
    constructor: (@_proxy) ->
        @_fields = []
        @_filters = []
        @_order = []
        @_limit = 0
        @_offset = 0
        @

    getProxy: () ->
        @_proxy

    setFields: (fields) ->
        @_fields = if _.isArray(fields) then fields else _.toArray(arguments)
        @

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

    fillManyToOneRelation: (models, relation) ->
        throw 'Absract method'

    fillOneToManyRelation: (models, relation) ->
        throw 'Absract method'

    fillManyToManyRelation: (models, relation) ->
        throw 'Absract method'

    fillVirtualOneToOneRelation: (models, relation) ->
        throw 'Absract method'

    fillVirtualOneToManyRelation: (models, relation) ->
        throw 'Absract method'

    fillRelation: (models, relation) ->
        if not models.length
            deferred = Q.defer()
            deferred.resolve()
            return deferred.promise

        config = models[0].schema.fields[relation]

        if config.m2m
            return @fillManyToManyRelation models, relation
        else if config.collection
            return @fillOneToManyRelation models, relation
        else
            return @fillManyToOneRelation models, relation


module.exports = DataRequest;