class DataProvider
    proxies: {}

    registerProxy: (alias, proxy) ->
        @proxies[alias] = proxy
        @

    getProxy: (alias) ->
        alias = alias.getProxyAlias() if alias? and alias.getProxyAlias
        alias = alias or 'default'
        @proxies[alias]

    createRequest: (model) ->
        @getProxy(model).createDataRequest model

module.exports = new DataProvider;