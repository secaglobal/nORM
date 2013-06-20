Validator = require("#{LIBS_PATH}/validator");


describe '@Validator', () ->
    describe 'Common', () ->
        describe '#required', () ->
            it 'should return true if object is not null', () =>
                expect(Validator.required 1).be.ok
                expect(Validator.required {}).be.ok
                expect(Validator.required 0).be.ok
                expect(Validator.required 'null').be.ok
                expect(Validator.required true).be.ok
                expect(Validator.required false).be.ok

            it 'should return false if object is null', () =>
                expect(Validator.required null).be.not.ok

    describe 'Number', () ->
        describe '#numeric', () ->
            it 'should return true if represented Number', () =>
                expect(Validator.numeric 1234).be.ok

            it 'should return true if represented string without illegal chars', () =>
                expect(Validator.numeric '1234').be.ok

            it 'should return false if represented string with illegal chars', () =>
                expect(Validator.numeric '1234ii').be.not.ok

        describe '#min', () ->
            it 'should return true if number greater then threshold', () ->
                expect(Validator.min '125', 123).be.ok

            it 'should return true if number equal to threshold', () ->
                expect(Validator.min '125', 125).be.ok

            it 'should return false if number less then threshold', () ->
                expect(Validator.min '125', 127).be.not.ok

        describe '#max', () ->
            it 'should return true if number less then threshold', () ->
                expect(Validator.max '125', 127).be.ok

            it 'should return true if number equal to threshold', () ->
                expect(Validator.max '125', 125).be.ok

            it 'should return false if number greater then threshold', () ->
                expect(Validator.max '125', 123).be.not.ok

        describe '#set', () ->
            it 'should return true if number is in predefined list', () ->
                expect(Validator.set 125, [1, 2, 125, 156]).be.ok

            it 'should return true if number is in predefined list', () ->
                expect(Validator.set 125, [1, 2, 126, 156]).be.not.ok

        describe '#preset', () ->
            it 'should return true if value fit to preset int', () ->
                expect(Validator.preset 1, 'int').be.ok
                expect(Validator.preset 125, 'int').be.ok
                expect(Validator.preset -2147483648, 'int').be.ok
                expect(Validator.preset 2147483647, 'int').be.ok
                expect(Validator.preset '144', 'int').be.ok

            it 'should return false if value not fit to preset int', () ->
                expect(Validator.preset 'not a number', 'int').be.not.ok
                expect(Validator.preset -2147483649, 'int').be.not.ok
                expect(Validator.preset 2147483648, 'int').be.not.ok
                expect(Validator.preset '2147483648', 'int').be.not.ok

            it 'should return true if value fit to preset tinyint', () ->
                expect(Validator.preset 1, 'tinyint').be.ok
                expect(Validator.preset 125, 'tinyint').be.ok
                expect(Validator.preset -128, 'tinyint').be.ok
                expect(Validator.preset 127, 'tinyint').be.ok
                expect(Validator.preset '120', 'tinyint').be.ok
            it 'should return false if value not fit to preset tinyint', () ->
                expect(Validator.preset 'not a number', 'tinyint').be.not.ok
                expect(Validator.preset -129, 'tinyint').be.not.ok
                expect(Validator.preset 128, 'tinyint').be.not.ok
                expect(Validator.preset '128', 'tinyint').be.not.ok

    describe 'String', () ->
        describe '#string', () ->
            it 'should return true if value is string', () ->
                expect(Validator.string 'string').be.ok

            it 'should return true if value is number', () ->
                expect(Validator.string 125).be.ok

            it 'should return true if value is not string or number', () ->
                expect(Validator.string {}).be.not.ok
                expect(Validator.string () -> ).be.not.ok

        describe '#length', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.len 'string', 6).be.ok
                expect(Validator.len 100000, 6).be.ok

            it 'should return false if value is not longer than threshold', () ->
                expect(Validator.len 'string', 7).be.not.ok
                expect(Validator.len 100000, 7).be.not.ok

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.len 'string', 5).be.not.ok
                expect(Validator.len 100000, 5).be.not.ok

        describe '#maxLen', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.maxLen 'string', 6).be.ok
                expect(Validator.maxLen 100000, 6).be.ok

            it 'should return true if value is shorter than threshold', () ->
                expect(Validator.maxLen 'string', 7).be.ok
                expect(Validator.maxLen 100000, 7).be.ok

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.maxLen 'string', 5).be.not.ok
                expect(Validator.maxLen 100000, 5).be.not.ok

        describe '#minLen', () ->
            it 'should return true if value has exact length', () ->
                expect(Validator.minLen 'string', 6).be.ok
                expect(Validator.minLen 100000, 6).be.ok

            it 'should return true if value is shorter than threshold', () ->
                expect(Validator.minLen 'string', 7).be.not.ok
                expect(Validator.minLen 100000, 7).be.not.ok

            it 'should return false if value is longer to threshold', () ->
                expect(Validator.minLen 'string', 5).be.ok
                expect(Validator.minLen 100000, 5).be.ok


        describe '#set', () ->
            it 'should return true if string is in predefined list', () ->
                expect(Validator.set 't1', ['t2', 't3', 't1', 't4']).be.ok

            it 'should return true if string is in predefined list', () ->
                expect(Validator.set 't1', ['t2', 't3', 't4']).be.not.ok

        describe '#regexp', () ->
            it 'should return true if nstring fit to regexp', () ->
                expect(Validator.regexp 'correct', /^\w+$/).be.ok

            it 'should return false if string miss the regexp', () ->
                expect(Validator.regexp 'not correct', /^\s+$/).be.not.ok


