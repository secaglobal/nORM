Builder = require("#{LIBS_PATH}/mysql/query-builder");


describe '@Mysql.QueryBuilder', () ->
    beforeEach ()->
        @builder = new Builder();
        @builder.setTable('Test')

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

        it 'should correctly bahave with $in, $nin directives', () ->
            @builder.setFilters
                name: {$eq: 'Liza'},
                id: {$nin: [20, 30, 40, 50]}
                age: {$in: [20, 30]}

            @builder.compose().should.equal \
                "select * from `Test` where `name`='Liza' and `id` not in('20','30','40','50') and `age` in('20','30')"

        it 'should correctly bahave with $or and $and directives', () ->
            @builder.setFilters
              name: {$eq: 'Liza'},
              $or: [
                  {
                    id: {$nin: [20, 30, 40, 50]}
                  },
                  {
                      age: {$in: [20, 30]},
                      type: 2
                  }
              ]

            @builder.compose().should.equal \
              "select * from `Test` where `name`='Liza' and ((`id` not in('20','30','40','50')) or (`age` in('20','30') and `type`='2'))"

    describe '#setLimit', () ->
        it 'should set limit clouse', () ->
            @builder.setLimit(10).compose().should.equal "select * from `Test` limit 10"

    describe '#setOffset', () ->
        it 'should set offset clouse', () ->
            @builder.setLimit(100).setOffset(10).compose().should.equal "select * from `Test` limit 100 offset 10"

    describe '#setOrder', () ->
        it 'should set order clouse', () ->
            @builder.setOrder({id: 1, name: -1}).compose().should.equal "select * from `Test` order by `id`,`name` desc"

    describe '#setFields', () ->
        it 'should be able to receive list of fields as array', () ->
            expect(@builder.setFields(['id', 'name'])._fields).be.deep.equal ['id', 'name']

        it 'should be able to receive list of fields as arguents', () ->
            expect(@builder.setFields('id', 'name')._fields).be.deep.equal ['id', 'name']

        it 'should set fields', () ->
            @builder.setFields('id', 'name').compose().should.equal "select `id`,`name` from `Test`"

    describe '#compose', () ->
        it 'should compose select queries', () ->
            @builder.compose().should.equal 'select * from `Test`'

        it 'should compose update queries', () ->
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
            @builder.setFields(['state', 'status']).insertValues([
                [1, 2],
                [2, 3],
                [3, 4]
            ])

            @builder.compose()
                .should.equal "insert into `Test`(`state`,`status`) values('1','2'),('2','3'),('3','4')"

    describe '#addMeta', () ->
        it 'should insert different meta tegs', () ->
            expect(@builder
                .addMeta(Builder.META__TOTAL_COUNT, Builder.META__NO_CACHE)
                .compose()
            ).equal 'select SQL_CALC_FOUND_ROWS SQL_NO_CACHE * from `Test`'

    describe '#hasMeta', () ->
        it 'should return true if meta was set', () ->
            @builder.addMeta Builder.META__TOTAL_COUNT, Builder.META__NO_CACHE
            expect(@builder.hasMeta(Builder.META__TOTAL_COUNT)).be.ok
            expect(@builder.hasMeta(Builder.META__NO_CACHE)).be.ok

        it 'should return false if meta was not set', () ->
            @builder.addMeta Builder.META__NO_CACHE
            expect(@builder.hasMeta(Builder.META__TOTAL_COUNT)).be.not.ok
            expect(@builder.hasMeta(Builder.META__NO_CACHE)).be.ok

