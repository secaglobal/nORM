class DataRequest
  constructor: (@_proxy) ->

  getProxy: () ->
    @_proxy

  setFilters: (@_filters) ->
    @

  setLimit: (@_limit) ->
    @

  setOrder: (@_order) ->
    @

  find: (model) ->
    throw 'Not implemented yet'

  save: (models) ->
    throw 'Not implemented yet'

  delete: (models) ->
    throw 'Not implemented yet'


module.exports = DataRequest;