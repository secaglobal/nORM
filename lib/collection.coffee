underscore = require 'underscore'
Q = require 'q'
Util = require './util'
DataProvider = require './data-provider'
Entity = require("./entity");
IModel = require("./imodel");

class Collection extends Entity
    constructor: (models, @config = {}) ->
        super()

        if !@config.model and models.length and models[0] instanceof IModel
            @config.model = models[0].self

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
            model = new @config.model(model) if not (model instanceof IModel)
            model.collection = @
            @models[i] = model

        @refreshLength()
        @

    first: () ->
        underscore.first(@models)

    at: (nr) ->
        @models[nr]

    where: (filter) ->
        underscore.where(@models, filter)

    findWhere: (filter) ->
        underscore.findWhere(@models, filter)

    pluck: (field) ->
        underscore.pluck(@models, field)

    isEmpty: () ->
        underscore.isEmpty(@models)

    forEach: (fn) ->
        underscore.forEach(@models, fn)

    refreshLength: () ->
        @length = @models.length
        @

    require: () ->
        deferred = Q.defer()
        fields = @config.model.schema.fields
        promises = []

        for field in arguments
            if fields[field].type.prototype instanceof IModel
                promises.push @_request.fillRelation(@models, field)

        Q.allResolved(promises).then (promises) ->
            promises.forEach (promise) ->
                if not promise.isFulfilled()
                    deferred.reject promise.valueOf().exception
                return
            deferred.resolve()

        deferred.promise



    load: () ->
        _this = @

        @_request.setFilters(@config.filters) if @config.filters
        @_request.setLimit(@config.limit) if @config.limit
        @_request.setOrder(@config.order) if @config.order
        @_request.setOffset(@config.offset) if @config.offset
        @_request.fillTotalCount() if @config.total

        @_request.find(@config.model).then (rows)->
            _this.total = rows.total if rows.total?
            _this.reset rows


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

