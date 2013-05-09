chai = require 'chai'
Builder = require("#{LIBS_PATH}/mysql/query-builder");

chai.should()

describe '@QueryBuilder', () ->
  beforeEach ()->
    @builder = new Builder();
    @builder.setType(Builder.TYPE__SELECT).setTable('Test')

  describe '#setTable', () ->
    it 'should set appropriate table', () ->
      @builder.compose().should.equal 'select * from Test'

  describe '#setFilters', () ->
    it 'should convert object to where clouse', () ->
      @builder.setFilters
        name: 'Liza'
        age: 20
        lastName: null

      @builder.compose().should.equal \
        "select * from Test where name='Liza',age='20',lastName is null"

    it 'should recognize $eq, $ne, $in, $nin, $lt, $lte an null directives', () ->
      @builder.setFilters
        name: {$eq: 'Liza'},
        age: {$ne: 20}

      @builder.compose().should.equal \
        "select * from Test where name='Liza',age!='20'"
  describe '#compose', () ->
    it 'should compose select queries', () ->
      @builder.compose().should.equal 'select * from Test'

    it 'should compose update queries'
    it 'should compose delete queries'
    it 'should compose insert queries'

