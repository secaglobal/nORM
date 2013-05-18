Backbone = require 'backbone'
_ = require 'underscore'
DataProvider = require './data-provider'
Model = require './model'

class Collection extends Backbone.Collection
    initialize: (models) ->
        @model = models[0].constructor if models.length and models[0] instanceof Model
        @_request = DataProvider.createRequest(@model) if @model

    getRequest: () ->
        @_request

    load: () ->
        _ = @
        @_request.find(@model).then (rows)->
            _.reset rows

    save: () ->
        @_request.save(@models)

    delete: () ->
        _ = @
        @_request.delete(@models).then ()->
            _.reset([])

    keys: () ->
        _.filter models.pluck(config.myKey || 'id'), (v) ->
            v > 0


module.exports = Collection;