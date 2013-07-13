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
            return
        else if _.isArray(value)
            if  _.isArray(value[0])
                @fields[attr] = {type: value[0][0], m2m: true, collection: true}
            else
                @fields[attr] = {type: value[0], collection: true}
        else if _.isFunction(value) #if model
            @fields[attr] = {type: value}
        else
            @fields[attr] = value

        @fields[attr].external = @fields[attr].type.prototype instanceof Model

        if not (@fields[attr] and @fields[attr].type.prototype instanceof Model)
            @keys.push attr

    getProxy: () ->
        @

    validate: (obj, isRecurcive) ->
        res = []
        for field, config of @fields
            value = obj[field];

            continue if config.external

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