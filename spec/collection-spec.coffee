chai = require 'chai'
Model = require("#{LIBS_PATH}/collection");

class TestModel extends Model

chai.should()

describe '@Collection', () ->
  beforeEach () ->

  describe '#load', () ->
    it 'should request rows via model proxy'
    it 'should return promise'
    it 'should fill collection with received models'

  describe '#save', () ->
    it 'should save all changed models'
    it 'should return promise'

  describe 'delete', () ->
    it 'should delete all changed models'
    it 'should return promise'
