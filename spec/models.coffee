Model = require("#{LIBS_PATH}/model");
Schema = require("#{LIBS_PATH}/schema");

class Country extends Model
    @schema: new Schema 'Country',
        title: String

class Job extends Model
    @schema: new Schema 'Job',
        title: String,
        salary: Number,
        countryId: Number,
        country: Country

class Task extends Model
    @schema: new Schema 'Task',
        id: Number
        title: String

class Car  extends Model
    @schema: new Schema 'Car',
        id: Number
        title: {type: String, require: true},
        personId: Number

class Person extends Model
    @schema: new Schema 'Person',
        id: Number
        name: {type: String, require: true},
        age: Number,
        jobId: Number,
        job: Job,
        tasks: [[Task]],
        cars: [Car],
        stateNice: () -> this.getStateNice()
        _proxy: 'test1'

    constructor: () ->
        super
        @_state = 'inspired'

    getStateNice: () ->
        @_state

    setStateNice: (@_state) ->


module.exports =
    Job: Job,
    Task: Task,
    Car: Car,
    Person: Person