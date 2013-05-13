class DataRequest
  constructor: (@_proxy) ->

  setFilters: (@_filters) ->
    @

  setLimit: (@_limit) ->
    @

  setOrder: (@_order) ->
    @

  find: (model) ->
    throw 'Not implemented yet'

module.exports = DataRequest;