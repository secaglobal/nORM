_ = require 'underscore'

class Schema
    fields: {id: {type: Number}}

    constructor: (@name, structure) ->
        @_applyAttr attr, value for attr, value of structure

    _applyAttr: (attr, value) ->

        if attr is '_proxy'
            @proxy = value
        else if _.isArray(value)
            if  _.isArray(value[0])
                @fields[attr] = {type: value[0][0], m2m: true, collection: true}
            else
                @fields[attr] = {type: value[0], collection: true}
        else if _.isFunction(value)
            @fields[attr] = {type: value}
        else
            @fields[attr] = value

    getProxy: () ->
        @

    validate: () ->
        @

module.exports = Schema