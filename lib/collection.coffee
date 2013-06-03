Backbone = require 'backbone'
_ = require 'underscore'
DataProvider = require './data-provider'
Model = require './model'

class Collection extends Backbone.Collection
    initialize: (models, config) ->
        @model = models[0].constructor if models.length and models[0] instanceof Model

        if config
            @_filters = config.filters
            @_order = config.order
            @_offset = config.offset
            @_limit = config.limit

        @_request = DataProvider.createRequest(@model) if @model

    getRequest: () ->
        @_request

    setFilters: (@_filters) ->
        @

    setLimit: (@_limit) ->
        @

    setOffset: (@_offset) ->
        @

    setOrder: (@_order) ->
        @

    load: () ->
        _ = @

        @_request.setFilters(@_filters) if @_filters
        @_request.setLimit(@_limit) if @_limit
        @_request.setOrder(@_order) if @_order
        @_request.setOffset(@_offset) if @_offset

        @_request.find(@model).then (rows)->
            _.reset rows


    save: () ->
        @_request.save(@models)

    delete: () ->
        _ = @
        @_request.delete(@models).then ()->
            _.reset([])

    keys: () ->
        _.filter models.pluck('id'), (v) ->
            v > 0

module.exports = Collection

