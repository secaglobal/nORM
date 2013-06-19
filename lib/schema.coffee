_ = require 'underscore'
Util = require './util'
Model = require './model'

class Schema
    fields: {id: {type: Number}}
    keys: []

    constructor: (@name, structure) ->
        @_applyAttr attr, value for attr, value of structure
        @defaultFieldName = Util.lcfirst(name) + 'Id'

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

        if not (@fields[attr] and @fields[attr].type.prototype instanceof Model)
            @keys.push attr

    getProxy: () ->
        @

    validate: (obj) ->
        @

module.exports = Schema