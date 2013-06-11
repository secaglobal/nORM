Provider = require("#{LIBS_PATH}/data-provider");
Proxy = require("#{LIBS_PATH}/mysql/proxy");
MysqlDataRequest = require("#{LIBS_PATH}/mysql/data-request");
Model = require("#{LIBS_PATH}/model");

Person = require('./models')['Person']

describe '@DataProvider', () ->
    beforeEach () ->
        @dataProvider = new Provider.constructor()
        @dataProvider.registerProxy('test1', new Proxy({test1: true}))
        @dataProvider.registerProxy('test2', new Proxy({test2: true}))


    describe '#getProxy', () ->
        it 'should return @DataProxy by alias in config', () ->
            proxy = @dataProvider.getProxy('test1')
            proxy.should.be.instanceOf Proxy
            proxy.getConfig().should.be.deep.equal {test1: true}

        it 'should return @DataProxy if defined @Model instead of alias', () ->
            proxy = @dataProvider.getProxy(Person)
            proxy.should.be.instanceOf Proxy
            proxy.getConfig().should.be.deep.equal {test1: true}


    describe '#createRequest', () ->
        it 'should return appropriate @DataRequest if defined Model', () ->
            @dataProvider.createRequest(Person).should.be.instanceof MysqlDataRequest