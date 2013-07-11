Schema = require("#{LIBS_PATH}/schema");
Model = require("#{LIBS_PATH}/model");
Validator = require("#{LIBS_PATH}/validator");

describe '@Schema', () ->
    beforeEach () ->
        sinon.spy(Validator,'len')
        sinon.spy(Validator,'maxLen')
        sinon.spy(Validator, 'required')
        sinon.spy(Validator, 'string')
        sinon.spy(Validator, 'numeric')

    afterEach () ->
        Validator.len.restore()
        Validator.maxLen.restore()
        Validator.required.restore()
        Validator.string.restore()
        Validator.numeric.restore()

    describe '#constructor', () ->
        it 'should handle simple structure', () ->
            schema = new Schema 'Car', title: {type: String}, nr:  {type: Number}
            expect(schema.fields.title).be.deep.equal {type: String}
            expect(schema.fields.nr).be.deep.equal {type: Number}

        it 'should handle types', () ->
            schema = new Schema 'Car', title: String, nr: Number
            expect(schema.fields.title).be.deep.equal {type: String, external: false}
            expect(schema.fields.nr).be.deep.equal {type: Number, external: false}

        it 'should handle collections', () ->
            schema = new Schema 'Car', parts: [Number]
            expect(schema.fields.parts).be.deep.equal {type: Number, collection: true, external: false}

        it 'should handle Many-to-Many relations', () ->
            schema = new Schema 'Car', parts: [[String]]
            expect(schema.fields.parts).be.deep.equal {type: String, m2m: true, collection: true, external: true}

        it 'should handler _proxy attribute', () ->
            schema = new Schema 'Car', _proxy: 'proxy'
            expect(schema.proxy).be.deep.equal 'proxy'

        it 'should set default field name for relations', () ->
            schema = new Schema 'Car', _proxy: 'proxy'
            expect(schema.defaultFieldName).be.deep.equal 'carId'

    describe '#validate', () ->
        it 'should skip collection, type and external fields', () ->
            schema = new Schema 'Car', name: {type: String, collection: false, external: false}
            expect(schema.validate({name: 'Valery'})).be.equal true

        it 'should execute all validators', () ->
            schema = new Schema 'Car', name: {type: String, required: true, maxLen: 10}
            schema.validate {name: 'Valery'}
            expect(Validator.maxLen.calledWith 'Valery', 10).be.equal true
            expect(Validator.required.calledWith 'Valery').be.equal true

        it 'should correctly validate fields with null value', () ->
            schema = new Schema 'Car', name: {type: String, required: true, maxLen: 10}
            schema.validate {name: null}
            expect(Validator.maxLen.calledWith null, 10).be.equal true
            expect(Validator.required.calledWith null).be.equal true

        it 'should correctly validate fields with undefined field', () ->
            schema = new Schema 'Car', name: {type: String, required: true, maxLen: 10}
            schema.validate {}
            expect(Validator.maxLen.calledWith undefined, 10).be.equal true
            expect(Validator.required.calledWith undefined).be.equal true

        it 'should validate numbers', () ->
            schema = new Schema 'Car', age: {type: Number}
            schema.validate {age: 10}
            expect(Validator.numeric.calledWith 10).be.equal true

        it 'should validate string', () ->
            schema = new Schema 'Car', name: {type: String}
            schema.validate {name: 'Valery'}
            expect(Validator.string.calledWith 'Valery').be.equal true

        it 'should ignore fields with Object type', () ->
            schema = new Schema 'Car', details: {type: Object}
            expect(schema.validate {details: {}}).be.equal true

        it 'should ignore fields with Model type', () ->
            class Detail extends Model
                @shema: new Schema 'Detail', title: String

            schema = new Schema 'Car', details: [Detail]
            expect(schema.validate {details: [new Detail({title: 'wheel'})]}).be.equal true

        it 'should ignore field validation if field is null or undefined', () ->
            schema = new Schema 'Car', age: Number
            console.log schema.validate {}
            expect(schema.validate {}).be.equal true
            expect(schema.validate {age: null}).be.equal true

        it 'should return list of fields with thier errors', () ->
            schema = new Schema 'Car',
                name: {type: String, required: true, maxLen: 10}
                registered: Date

            res = schema.validate {registered: new Date('2010-03-14')}

            expect(res.length).be.equal 1
            expect(res[0].field).be.equal 'name'
            expect(res[0].error.code).be.equal "VALIDATOR__ERROR__MAX_LEN"




