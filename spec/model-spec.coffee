chai = require 'chai'
Model = require("#{LIBS_PATH}/model");

class DefaultModel extends Model

class RedefinedModel extends DefaultModel
  @PROXY_ALIAS: 'second'

chai.should()

describe '@Model', () ->
  beforeEach () ->
    @defaultModel = new DefaultModel
    @redefinedModel = new RedefinedModel

  describe '#getProxyAlias', () ->
    it 'should return default proxy alias', () ->
      proxy = DefaultModel.getProxyAlias()
      proxy.should.be.equal 'default'

    it 'should return redefined proxy alias', () ->
      proxy = RedefinedModel.getProxyAlias()
      proxy.should.be.equal 'second'
