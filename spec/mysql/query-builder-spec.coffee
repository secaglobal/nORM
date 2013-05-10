chai = require 'chai'
Builder = require("#{LIBS_PATH}/mysql/query-builder");

chai.should()

describe '@QueryBuilder', () ->
  beforeEach ()->
    @builder = new Builder();
    @builder.setType(Builder.TYPE__SELECT).setTable('Test')

  describe '#setTable', () ->
    it 'should set appropriate table', () ->
      @builder.compose().should.equal 'select * from `Test`'

  describe '#setFilters', () ->
    it 'should convert object to where clouse', () ->
      @builder.setFilters
        name: 'Liza'
        age: 20
        lastName: null

      @builder.compose().should.equal \
        "select * from `Test` where `name`='Liza' and `age`='20' and `lastName` is null"

    it 'should correctly bahave with $eq and $ne directives', () ->
      @builder.setFilters
        name: {$eq: 'Liza'},
        age: {$ne: 20}

      @builder.compose().should.equal \
        "select * from `Test` where `name`='Liza' and `age`!='20'"

    it 'should correctly bahave with $lt, $lte, $gt and $gte directives', () ->
      @builder.setFilters
        age: {$gt: 20},
        weight: {$gte: 60},
        height: {$lt: 180},
        width: {$lte: 120},

      @builder.compose().should.equal \
        "select * from `Test` where `age`>'20' and `weight`>='60' and `height`<'180' and `width`<='120'"

    it 'should correctly bahave with null values', () ->
      @builder.setFilters
        name: {$eq: 'Liza'},
        age: null

      @builder.compose().should.equal \
        "select * from `Test` where `name`='Liza' and `age` is null"

    it 'should correctly bahave $in, $nin directives', () ->
      @builder.setFilters
        name: {$eq: 'Liza'},
        id: {$nin: [20, 30, 40, 50]}
        age: {$in: [20, 30]}

      @builder.compose().should.equal \
        "select * from `Test` where `name`='Liza' and `id` not in('20','30','40','50') and `age` in('20','30')"

  describe '#compose', () ->
    it 'should compose select queries', () ->
      @builder.compose().should.equal 'select * from `Test`'

    it 'should compose update queries', () ->
      @builder.setType Builder.TYPE__UPDATE
      @builder.updateFields
          state: 1,
          status: 2

      @builder.setFilters
          id: 4,
          date: {$gt: '2010-12-12'}

      @builder.compose()
        .should.equal "update `Test` set `state`='1',`status`='2' where `id`='4' and `date`>'2010-12-12'"

    it 'should compose delete queries', () ->
      @builder.setType Builder.TYPE__DELETE

      @builder.setFilters
        id: 4,
        date: {$gt: '2010-12-12'}

      @builder.compose()
        .should.equal "delete from `Test` where `id`='4' and `date`>'2010-12-12'"

    it 'should compose insert queries', () ->
      @builder.setType Builder.TYPE__INSERT
      @builder.insertRows ['state', 'status'], [1, 2], [2, 3], [3, 4]

      @builder.compose()
        .should.equal "insert into `Test`(`state`,`status`) values('1','2'),('2','3'),('3','4')"


