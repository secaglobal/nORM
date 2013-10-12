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
        title: String

class Car  extends Model
    @schema: new Schema 'Car',
        title: String,
        personId: Number

class Person extends Model
    @schema: new Schema 'Person',
        name: String,
        age: Number,
        jobId: Number,
        job: Job,
        tasks: [[Task]],
        cars: [Car],

module.exports =
    Job: Job,
    Task: Task,
    Car: Car,
    Person: Person