_ = require 'underscore'
Util = require './util'
Model = require './model'
Validator = require './validator'

class Schema
    constructor: (@name, structure) ->
        @fields = {id: {type: Number}}
        @keys = []
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
        for field, config of @fields
            value = obj[field];
            for validator, params of config
                if validator in ['collection', 'm2m']
                    continue

                if validator is 'type'
                    switch params
                        when String then Validator.string value
                        when Number then Validator.numeric value
                else
                    Validator[validator](value, params)



module.exports = Schema