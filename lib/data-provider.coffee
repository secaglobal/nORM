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
        proxy = @getProxy(model)
        return proxy.createDataRequest model if proxy
        throw "Proxy not found"

module.exports = new DataProvider;