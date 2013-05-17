chai = require 'chai'

global.LIBS_PATH = "#{__dirname}/../lib"

chai.should()
global.expect = chai.expect
global.sinon = require 'sinon'

#class A
#  @hasMany: (field, config) ->
#    @::[field] = [models, config]
#
#  @belongTo: (field, config)->
#    @::[field] = [models, config]
#
#class C extends A
#  @belongsTo 'owner', use: A
#
#class B extends A
#  @hasMany 'users', use: B
#  @belongsTo 'owner', use: A, key: 'ownerId'



