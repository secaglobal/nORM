_ = require 'underscore'
Q = require 'q'
Util = require './util'
DataProvider = require './data-provider'
Entity = require("./entity");
IModel = require("./imodel");

class Collection extends Entity
    constructor: (models, @config = {}) ->
        super()
        @models = []

        if not _.isArray models
            [models, @config] = [@config, models]

        if !@config.model and models.length and models[0] instanceof IModel
            @config.model = models[0].self

        @reset(models) if models.length
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

    setFields: (fields) ->
        @config.fields = []
        @config.relations = {}
        fields = _.toArray(arguments) if not _.isArray(fields)
        schemaFields = @config.model.schema.fields

        for field in fields
            if (ind = field.indexOf('.')) > 0
                subfield = field.substring(ind + 1);
                field = field.substring(0, ind);

            if schemaFields[field].external
                if not @config.relations[field]
                    @config.relations[field] = []
                @config.relations[field].push subfield if subfield
            else
                @config.fields.push field

        @

    reset: (@models) ->
        for model, i in @models
            model = new @config.model(model) if not (model instanceof IModel)
            model.collection = @
            @models[i] = model

        @refreshLength()
        @

    first: () ->
        _.first(@models)

    at: (nr) ->
        @models[nr]

    where: (filter) ->
        _.where(@models, filter)

    findWhere: (filter) ->
        _.findWhere(@models, filter)

    pluck: (field) ->
        _.pluck(@models, field)

    isEmpty: () ->
        _.isEmpty(@models)

    forEach: (fn) ->
        _.forEach(@models, fn)

    toJSON: () ->
        @models

    refreshLength: () ->
        @length = @models.length
        @

    require: () ->
        _this = @
        deferred = Q.defer()
        fields = @config.model.schema.fields
        promises = []

        for field in arguments
            if fields[field].type.prototype instanceof IModel
                promises.push @_request.fillRelation(@, field)

        Q.allSettled(promises).then (results) ->
            results.forEach (result) ->
                if result.state isnt "fulfilled"
                    deferred.reject result.reason
            deferred.resolve(_this)

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
            _this._fillRelations()

    _fillRelations: () ->
        _this = @
        promises = []
        deferred = Q.defer()
        relations = @config.relations || {}

        for relation, fields  of relations
            promises.push @_request.fillRelation(@, relation, fields)

        Q.allSettled(promises).then (results) ->
            results.forEach (result) ->
                if result.state isnt "fulfilled"
                    deferred.reject result.reason
            deferred.resolve(_this)

        deferred.promise

    save: () ->
        @_request.save(@models)

    delete: () ->
        _this = @
        @_request.delete(@models).then ()->
            _this.reset([])

module.exports = Collection

