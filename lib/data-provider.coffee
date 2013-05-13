Model = require './model'
class DataProvider
  proxies: {}

  registerProxy: (alias, proxy) ->
    @proxies[alias] = proxy
    @

  getProxy: (alias) ->
    @proxies[ if alias? and alias.getProxyAlias then alias.getProxyAlias() else alias ]

  createRequest: (model) ->
    @getProxy(model).createDataRequest model

module.exports = new DataProvider;