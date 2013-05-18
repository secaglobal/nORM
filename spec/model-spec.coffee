Model = require("#{LIBS_PATH}/model");
dataProvider = require("#{LIBS_PATH}/data-provider");

class DefaultModel extends Model

class RedefinedModel extends DefaultModel
    @PROXY_ALIAS: 'test1'

describe '@Model', () ->
    beforeEach () ->
#    @proxy = new Proxy({test1: true})
#    dataProvider.registerProxy('test1', @proxy)
#
#    @model = new RedefinedModel


    describe '#getProxyAlias', () ->
        it 'should return default proxy alias', () ->
            proxy = DefaultModel.getProxyAlias()
            proxy.should.be.equal 'default'

        it 'should return redefined proxy alias', () ->
            proxy = RedefinedModel.getProxyAlias()
            proxy.should.be.equal 'test1'

#  describe '#belongsTo', () ->
#    it 'should set up @DataRequest and execute perform', () ->
#
#    it 'should return promise'
#    it 'should pass Model when request will be executed'
