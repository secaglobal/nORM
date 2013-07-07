Model = require("#{LIBS_PATH}/model");
Schema = require("#{LIBS_PATH}/schema");

class Job extends Model
    @schema: new Schema 'Job',
        id: Number
        title: String,
        salary: Number

class Task extends Model
    @schema: new Schema 'Task',
        id: Number
        title: String

class Car  extends Model
    @schema: new Schema 'Car',
        id: Number
        title: String,
        personId: Number

class Person extends Model
    @schema: new Schema 'Person',
        id: Number
        name: String,
        age: Number,
        jobId: Number,
        job: Job,
        tasks: [[Task]],
        cars: [Car],
        _proxy: 'test1'

module.exports =
    Job: Job,
    Task: Task,
    Car: Car,
    Person: Person