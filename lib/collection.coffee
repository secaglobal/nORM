Backbone = require 'backbone'
DataProvider = require './data-provider'

class Collection extends Backbone.Collection
  initialize: () ->
    @_request = DataProvider.createRequest(@model)

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


module.exports = Collection;