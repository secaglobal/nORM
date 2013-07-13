Validator = require("#{LIBS_PATH}/validator");


describe '@Validator', () ->
    describe 'Common', () ->
        describe '#require', () ->
            it 'should return true if object is not null', () =>
                expect(Validator.require 1).be.equal true
                expect(Validator.require {}).be.equal true
                expect(Validator.require 0).be.equal true
                expect(Validator.require 'null').be.equal true
                expect(Validator.require true).be.equal true
                expect(Validator.require false).be.equal true

            it 'should return false if object is null', () =>
                expect(Validator.require(null).code).be.equal 'VALIDATOR__ERROR__REQUIRE'

    describe 'Number', () ->
        describe '#numeric', () ->
            it 'should return true if represented Number', () =>
                expect(Validator.numeric 1234).be.equal true

            it 'should return true if represented string without illegal chars', () =>
                expect(Validator.numeric '1234').be.equal true

            it 'should return false if represented string with illegal chars', () =>
                expect(Validator.numeric('1234ii').code).be.equal 'VALIDATOR__ERROR__NUMERIC'

        describe '#min', () ->
            it 'should return true if number greater then threshold', () ->
                expect(Validator.min '125', 123).be.equal true

            it 'should return true if number equal to threshold', () ->
                expect(Validator.min '125', 125).be.equal true

            it 'should return false if number less then threshold', () ->
                expect(Validator.min('125', 127).code).be.equal 'VALIDATOR__ERROR__MIN'

        describe '#max', () ->
            it 'should return true if number less then threshold', () ->
                expect(Validator.max '125', 127).be.equal true

            it 'should return true if number equal to threshold', () ->
                expect(Validator.max '125', 125).be.equal true

            it 'should return false if number greater then threshold', () ->
                expect(Validator.max('125', 123).code).be.equal 'VALIDATOR__ERROR__MAX'

        describe '#set', () ->
            it 'should return true if number is in predefined list', () ->
                expect(Validator.set 125, [1, 2, 125, 156]).be.equal true

            it 'should return true if number is in predefined list', () ->
                expect(Validator.set(125, [1, 2, 126, 156]).code).be.equal 'VALIDATOR__ERROR__SET'

        describe '#preset', () ->
            it 'should return true if value fit to preset int', () ->
                expect(Validator.preset 1, 'int').be.equal true
                expect(Validator.preset 125, 'int').be.equal true
                expect(Validator.preset -2147483648, 'int').be.equal true
                expect(Validator.preset 2147483647, 'int').be.equal true
                expect(Validator.preset '144', 'int').be.equal true

            it 'should return false if value not fit to preset int', () ->

                expect(Validator.preset('not a number', 'int').code).be.equal 'VALIDATOR__ERROR__NUMERIC'
                expect(Validator.preset(-2147483649, 'int').code).be.equal 'VALIDATOR__ERROR__MIN'
                expect(Validator.preset(2147483648, 'int').code).be.equal 'VALIDATOR__ERROR__MAX'
                expect(Validator.preset('2147483648', 'int').code).be.equal 'VALIDATOR__ERROR__MAX'

            it 'should return true if value fit to preset tinyint', () ->
                expect(Validator.preset 1, 'tinyint').be.equal true
                expect(Validator.preset 125, 'tinyint').be.equal true
                expect(Validator.preset -128, 'tinyint').be.equal true
                expect(Validator.preset 127, 'tinyint').be.equal true
                expect(Validator.preset '120', 'tinyint').be.equal true

            it 'should return false if value not fit to preset tinyint', () ->
                expect(Validator.preset('not a number', 'tinyint').code).be.equal 'VALIDATOR__ERROR__NUMERIC'
                expect(Validator.preset(-129, 'tinyint').code).be.equal 'VALIDATOR__ERROR__MIN'
                expect(Validator.preset(128, 'tinyint').code).be.equal 'VALIDATOR__ERROR__MAX'
                expect(Validator.preset('128', 'tinyint').code).be.equal 'VALIDATOR__ERROR__MAX'

    describe 'String', () ->
        describe '#string', () ->
            it 'should return true if value is string', () ->
                expect(Validator.string 'string').be.equal true

            it 'should return true if value is number', () ->
                expect(Validator.string 125).be.equal true

            it 'should return true if value is not string or number', () ->
                expect(Validator.string({}).code).be.equal 'VALIDATOR__ERROR__STRING'
                expect(Validator.string(() ->).code).be.equal 'VALIDATOR__ERROR__STRING'

        describe '#length', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.len 'string', 6).be.equal true
                expect(Validator.len 100000, 6).be.equal true

            it 'should return false if value is not longer than threshold', () ->
                expect(Validator.len('string', 7).code).be.equal 'VALIDATOR__ERROR__LEN'
                expect(Validator.len(100000, 7).code).be.equal 'VALIDATOR__ERROR__LEN'

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.len('string', 5).code).be.equal 'VALIDATOR__ERROR__LEN'
                expect(Validator.len(100000, 5).code).be.equal 'VALIDATOR__ERROR__LEN'

        describe '#maxLen', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.maxLen 'string', 6).be.equal true
                expect(Validator.maxLen 100000, 6).be.equal true

            it 'should return true if value is shorter than threshold', () ->
                expect(Validator.maxLen 'string', 7).be.equal true
                expect(Validator.maxLen 100000, 7).be.equal true

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.maxLen('string', 5).code).be.equal 'VALIDATOR__ERROR__MAX_LEN'
                expect(Validator.maxLen(100000, 5).code).be.equal 'VALIDATOR__ERROR__MAX_LEN'

        describe '#minLen', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.minLen 'string', 6).be.equal true
                expect(Validator.minLen 100000, 6).be.equal true

            it 'should return true if value is shorter than threshold', () ->
                expect(Validator.minLen('string', 7).code).be.equal 'VALIDATOR__ERROR__MIN_LEN'
                expect(Validator.minLen(100000, 7).code).be.equal 'VALIDATOR__ERROR__MIN_LEN'

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.minLen 'string', 5).be.equal true
                expect(Validator.minLen 100000, 5).be.equal true


        describe '#set', () ->
            it 'should return true if string is in predefined list', () ->
                expect(Validator.set 't1', ['t2', 't3', 't1', 't4']).be.equal true

            it 'should return true if string is in predefined list', () ->
                expect(Validator.set('t1', ['t2', 't3', 't4']).code).be.equal 'VALIDATOR__ERROR__SET'

        describe '#regexp', () ->
            it 'should return true if nstring fit to regexp', () ->
                expect(Validator.regexp 'correct', /^\w+$/).be.equal true

            it 'should return false if string miss the regexp', () ->
                expect(Validator.regexp('not correct', /^\s+$/).code).be.equal 'VALIDATOR__ERROR__REGEXP'


