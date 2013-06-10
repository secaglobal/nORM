MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Schema = require "#{LIBS_PATH}/schema"
VirtualSchema = require "#{LIBS_PATH}/virtual-schema"
Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
DataProvider = require "#{LIBS_PATH}/data-provider"


CompanySchema = new Schema 'Company',
    title: String

class Company extends Model
    @schema: CompanySchema

JobSchema = new VirtualSchema 'Job',
    title: String,
    salary: Number,
    company: Company

PersonSchema = new Schema 'Person',
    name: String,
    age: Number
    job: [JobSchema]

class Person extends Model
    @schema: CompanySchema


describe 'Complex interaction with relations', () ->
    describe 'Creation', () ->
        it 'should save model'

    describe 'Fields access',  () ->
        it 'should directly access top level fields'

