Schema = require("#{LIBS_PATH}/schema");
Model = require("#{LIBS_PATH}/model");
Validator = require("#{LIBS_PATH}/validator");

Person = require('./models')['Person']

describe '@Schema', () ->
    beforeEach () ->
        sinon.spy(Validator,'len')
        sinon.spy(Validator,'maxLen')
        sinon.spy(Validator, 'require')
        sinon.spy(Validator, 'string')
        sinon.spy(Validator, 'numeric')

    afterEach () ->
        Validator.len.restore()
        Validator.maxLen.restore()
        Validator.require.restore()
        Validator.string.restore()
        Validator.numeric.restore()

    describe '#constructor', () ->
        it 'should handle simple structure', () ->
            schema = new Schema 'Car', title: {type: String}, nr:  {type: Number}, owner: {type: Person}
            expect(schema.fields.title).be.deep.equal {type: String, external: false}
            expect(schema.fields.nr).be.deep.equal {type: Number, external: false}
            expect(schema.fields.owner).be.deep.equal {type: Person, external: true}

        it 'should handle types', () ->
            schema = new Schema 'Car', title: String, nr: Number
            expect(schema.fields.title).be.deep.equal
                type: String,
                dependent: false
                external: false,
                collection: false

            expect(schema.fields.nr).be.deep.equal
                type: Number,
                external: false,
                dependent: false,
                collection: false

        it 'should handle collections', () ->
            schema = new Schema 'Car', parts: [Number]
            expect(schema.fields.parts).be.deep.equal
                type: Number,
                collection: true,
                external: false,
                dependent: true

        it 'should handle Many-to-Many relations', () ->
            schema = new Schema 'Car', parts: [[String]]
            expect(schema.fields.parts).be.deep.equal
                type: String,
                m2m: true,
                collection: true,
                external: false,
                dependent: false

        it 'should handler _proxy attribute', () ->
            schema = new Schema 'Car', _proxy: 'proxy'
            expect(schema.proxy).be.deep.equal 'proxy'

        it 'should set default field name for relations', () ->
            schema = new Schema 'Car', _proxy: 'proxy'
            expect(schema.defaultFieldName).be.deep.equal 'carId'

        it 'should keep separate names of relation fields', () ->
            schema = new Schema 'Car',
                title: String,
                owner: Person,
                masters: [[Person]],
                someone: [Person]

            expect(schema.relations).be.deep.equal ['owner', 'masters', 'someone']

        it 'should keep separate names for dependant relation fields', () ->
            schema = new Schema 'Car',
                title: String,
                owner: Person,
                masters: [[Person]],
                someone: [Person]

            expect(schema.dependentRelations).be.deep.equal ['someone']

    describe '#validate', () ->
        it 'should skip collection, type, dependent and external fields', () ->
            schema = new Schema 'Car', name: {type: String, collection: false, external: false, dependent: true}
            expect(schema.validate({name: 'Valery'})).be.equal true

        it 'should execute all validators', () ->
            schema = new Schema 'Car', name: {type: String, require: true, maxLen: 10}
            schema.validate {name: 'Valery'}
            expect(Validator.maxLen.calledWith 'Valery', 10).be.equal true
            expect(Validator.require.calledWith 'Valery').be.equal true

        it 'should correctly validate fields with null value', () ->
            schema = new Schema 'Car', name: {type: String, require: true, maxLen: 10}
            schema.validate {name: null}
            expect(Validator.maxLen.calledWith null, 10).be.equal true
            expect(Validator.require.calledWith null).be.equal true

        it 'should correctly validate fields with undefined field', () ->
            schema = new Schema 'Car', name: {type: String, require: true, maxLen: 10}
            schema.validate {}
            expect(Validator.maxLen.calledWith undefined, 10).be.equal true
            expect(Validator.require.calledWith undefined).be.equal true

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

            schema = new Schema 'Car', details: {type: Detail, require: true}
            expect(schema.validate {}).be.equal true

        it 'should ignore field validation if field is null or undefined', () ->
            schema = new Schema 'Car', age: Number

            expect(schema.validate {}).be.equal true
            expect(schema.validate {age: null}).be.equal true

        it 'should return false if validation completed with errors', () ->
            schema = new Schema 'Car',
                name: {type: String, require: true, minLen: 10}
                registered: Date

            res = schema.validate {registered: new Date('2010-03-14'), name: 'Short'}

            expect(res).be.not.ok


        it 'should fill second argument by errors if provided', () ->
            schema = new Schema 'Car',
                name: {type: String, require: true, minLen: 10}
                registered: Date

            schema.validate {registered: new Date('2010-03-14'), name: 'Short'}, errors = []

            expect(errors.length).be.equal 1
            expect(errors[0].field).be.equal 'name'
            expect(errors[0].error.code).be.equal "VALIDATOR__ERROR__MIN_LEN"

        it 'should be possible to recursively validate', () ->
            validated = Person.schema.validate {
                name: 'Rex',
                job: {id: 2},
                cars: [{id: 4}]
            }, errors = [], true

            expect(validated).be.equal false
            expect(errors.length).be.equal 1
            expect(errors[0].field).be.equal 'cars'




