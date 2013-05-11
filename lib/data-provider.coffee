class DataProvider
  proxies: {}

  registerProxy: (alias, proxy) ->
    @proxies[alias] = proxy
    @

  getProxy: (alias)->
    @proxies[alias]

module.exports = new DataProvider;