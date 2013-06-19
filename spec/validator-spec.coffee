Validator = require("#{LIBS_PATH}/validator");


describe '@Validator', () ->
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

        describe '#enum', () ->
            it 'should return true if number in predefined list', () ->
                expect(Validator.enum 125, [1, 2, 125, 156]).be.ok

            it 'should return true if number in predefined list', () ->
                expect(Validator.enum 125, [1, 2, 126, 156]).be.not.ok

        it 'should validate enums'
        it 'should validate by preset' #int, type

    describe 'String', () ->
        it 'should validate string'
        it 'should validate length'
        it 'should validate max length'
        it 'should validate min length'
        it 'should validate enums'
        it 'should validate regexp'


