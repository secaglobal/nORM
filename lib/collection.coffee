Backbone = require 'backbone'
DataProvider = require './data-provider'

class Collection extends Backbone.Collection
  initialize: () ->
    @_request = DataProvider.createRequest(@model)

  getRequest: () ->
    @_request

  load: () ->
    @_request.find(@model)


module.exports = Collection;