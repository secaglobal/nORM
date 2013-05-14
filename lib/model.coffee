Backbone = require 'backbone'

class Model extends Backbone.Model
  @getProxyAlias: () ->
    @PROXY_ALIAS or 'default'

module.exports = Model;