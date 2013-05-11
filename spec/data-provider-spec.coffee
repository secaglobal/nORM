chai = require 'chai'
Provider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");

chai.should()

describe '@DataProvider', () ->
  beforeEach () ->
    @model = {}
    @dataProvider = new Provider.constructor()
    @dataProvider.registerProxy('test1', new Proxy({}))
    @dataProvider.registerProxy('test2', new Proxy({}))


  describe '#getProxy', () ->
    it 'should return @DataAdapter by alias in config', () ->
      proxy = @dataProvider.getProxy('test1')
      proxy.should.be.instanceOf Proxy