_ = require 'underscore'
Q = require 'q'
Util = require './util'
DataProvider = require './data-provider'
Entity = require("./entity");

class Collection extends Entity
    constructor: (models, @config) ->
        super()
        @reset(models)
        @_request = DataProvider.createRequest(@config.model)


    getRequest: () ->
        @_request

    setFilters: (filters) ->
        @config.filters = filters
        @

    setLimit: (limit) ->
        @config.limit = limit
        @

    setOffset: (offset) ->
        @config.offset = offset
        @

    setOrder: (order) ->
        @config.order = order
        @

    reset: (@models) ->
        for model, i in @models
            @models[i] = new @config.model(model) if Util.isHashMap(model)
        @refreshLength()
        @

    first: () ->
        _.first(@models)

    at: (nr) ->
        @models[nr]

    refreshLength: () ->
        @length = @models.length
        @

    require: () ->
        deferred = Q.defer()
        fields = @config.model.schema.fields
        promises = []

        for field in arguments
            if fields[field].type.prototype instanceof Entity
                promises.push @_request.fillRelation(@models, field)

        Q.allResolved(promises).then (promises) ->
            promises.forEach (promise) ->
                if not promise.isFulfilled()
                    deferred.reject promise.valueOf().exception
                return
            deferred.resolve()

        deferred.promise



    load: () ->
        _ = @

        @_request.setFilters(@config.filters) if @config.filters
        @_request.setLimit(@config.limit) if @config.limit
        @_request.setOrder(@config.order) if @config.order
        @_request.setOffset(@config.offset) if @config.offset

        @_request.find(@config.model).then (rows)->
            _.reset rows


    save: () ->
        @_request.save(@models)

    delete: () ->
        _ = @
        @_request.delete(@models).then ()->
            _.reset([])
#
#    keys: () ->
#        _.filter models.pluck('id'), (v) ->
#            v > 0

module.exports = Collection

