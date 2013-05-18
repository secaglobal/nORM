Backbone = require 'backbone'
dataProvider = require("./data-provider");
Q = require 'q'

class Model extends Backbone.Model
    @RELATION_TYPE__ONE_TO_ONE: 1
    @RELATION_TYPE__MANY_TO_ONE: 2
    @RELATION_TYPE__ONE_TO_MANY: 3
    @RELATION_TYPE__MANY_TO_MANY: 4

    constructor: () ->
        super
        @_relationsCache = {}

    @hasManyAndBelongsTo: (field, config) ->
        config.type = @RELATION_TYPE__MANY_TO_MANY
        @addRelation field, config

    @hasMany: (field, config) ->
        config.type = @RELATION_TYPE__ONE_TO_MANY
        @addRelation field, config

    @hasOne: (field, config) ->
        config.type = @RELATION_TYPE__ONE_TO_ONE
        @addRelation field, config

    @belongsTo: (field, config = [])->
        config.type = @RELATION_TYPE__MANY_TO_ONE
        @addRelation field, config

    @addRelation: (field, config) ->
        config.field = field
        @::[field] = () ->
            @_resolveRelation(field, config)
        @::[field].config = config

    _resolveRelation: (relation, config) ->
        _ = @
        field = @[relation]
        cache = @_relationsCache[relation]

        if cache
            deferred = Q.defer()
            deferred.resolve \
                if cache.isEmpty() then null else field.cache.first()
            return deferred.promise

        request = dataProvider.createRequest @constructor

        switch config.type
            when Model.RELATION_TYPE__MANY_TO_ONE
                return request.fillManyToOneRelation([@], relation).then () ->
                    @_relationsCache[relation].first()

    setRelation: (relation, collection) ->
        @_relationsCache[relation] = collection

    @getProxyAlias: () ->
        @PROXY_ALIAS or 'default'

module.exports = Model;