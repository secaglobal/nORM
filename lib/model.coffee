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

    clearRelations: () ->
        @_relationsCache = {}

    @hasAndBelongsToMany: (field, config) ->
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
        cache = @_relationsCache[relation]

        if cache
            deferred = Q.defer()
            deferred.resolve @_getSuitableRelationRepresentation(relation)
            return deferred.promise

        request = dataProvider.createRequest @constructor

        handlers = {}
        handlers[Model.RELATION_TYPE__MANY_TO_ONE] = request.fillManyToOneRelation
        handlers[Model.RELATION_TYPE__ONE_TO_MANY] = request.fillOneToManyRelation
        handlers[Model.RELATION_TYPE__MANY_TO_MANY] = request.fillManyToManyRelation

        handler = handlers[config.type]

        throw "Cannot recognize type pf relation '#{relation}'" if not handler

        return handler([@], relation).then () ->
            _._getSuitableRelationRepresentation(relation)

    _getSuitableRelationRepresentation: (relation) ->
        if @[relation].config.type == Model.RELATION_TYPE__MANY_TO_ONE
            return @_relationsCache[relation].first()
        else
            return @_relationsCache[relation]

    setRelation: (relation, collection) ->
        @_relationsCache[relation] = collection

    @getProxyAlias: () ->
        @PROXY_ALIAS or 'default'

module.exports = Model;