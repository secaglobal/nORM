Schema = require './schema'

class VirtualSchema extends Schema
    constructor: () ->
        super
        @_options.virtual = true


module.exports = VirtualSchema