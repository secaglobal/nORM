Backbone = require 'backbone'
DataProvider = require './data-provider'

class Collection extends Backbone.Collection
  initialize: () ->
    @_request = DataProvider.createRequest(@model)

  getRequest: () ->
    @_request

  load: () ->
    _ = @
    @_request.find(@model).then () ->
      console.log(arguments)


module.exports = Collection;