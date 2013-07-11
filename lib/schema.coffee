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
                @fields[attr] = {type: value[0][0], m2m: true, collection: true, external: true}
            else
                @fields[attr] = {type: value[0], collection: true, external: value[0].prototype instanceof Model}
        else if _.isFunction(value) #if model
            @fields[attr] = {type: value, external: value.prototype instanceof Model}
        else
            @fields[attr] = value

        if not (@fields[attr] and @fields[attr].type.prototype instanceof Model)
            @keys.push attr

    getProxy: () ->
        @

    validate: (obj) ->
        res = []
        for field, config of @fields
            value = obj[field];
            for validator, params of config
                if validator in ['collection', 'm2m', 'external']
                    continue

                validatorRes = true

                if validator is 'type'
                    if value?
                        switch params
                            when String then validatorRes = Validator.string value
                            when Number then validatorRes = Validator.numeric value
                else
                    validatorRes = Validator[validator](value, params)

                if not (validatorRes is true)
                    res.push field: field, error: validatorRes
        return if res.length then res else true


module.exports = Schema