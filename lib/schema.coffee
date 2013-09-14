_ = require 'underscore'
Util = require './util'
Model = require './model'
Validator = require './validator'

class Schema
    constructor: (@name, structure) ->
        @fields = {id: {type: Number}}
        @relations = []
        @dependentRelations = []
        @keys = []
        @_applyAttr attr, value for attr, value of structure
        @defaultFieldName = Util.lcfirst(name) + 'Id'

    _applyAttr: (attr, value) ->

        if attr is '_proxy'
            @proxy = value
            return
        else if _.isArray(value)
            if  _.isArray(value[0])
                @fields[attr] =
                    type: value[0][0],
                    m2m: true,
                    collection: true,
                    dependent: false
            else
                @fields[attr] = {type: value[0], collection: true, dependent: true}
        else if _.isFunction(value) #if model
            @fields[attr] = {type: value, dependent: false, collection: false}
        else
            @fields[attr] = value

        @fields[attr].external = @fields[attr].type.prototype instanceof Model

        if not (@fields[attr].type.prototype instanceof Model)
            @keys.push attr
        else
            @relations.push attr
            @dependentRelations.push attr if @fields[attr].dependent

    getProxy: () ->
        @

    validate: (obj, errors, recurcive = false) ->
        hasErrors = false

        for field, config of @fields
            value = obj[field];

            if config.external
                if recurcive and value? and config.dependent
                    err = []

                    if value.validate?
                        value.validate(err, true)
                    else
                        config.type.schema.validate value, err, true

                    if err.length
                        hasErrors = true
                        errors.push field: field, error: err if errors

                continue

            for validator, params of config
                if validator in ['collection', 'm2m', 'external', 'dependent']
                    continue

                validatorRes = true

                if validator is 'type'
                    if value?
                        switch params
                            when String then validatorRes = Validator.string value
                            when Number then validatorRes = Validator.numeric value
                else
                    validatorRes = Validator[validator](value, params)

                if validatorRes isnt true
                    hasErrors = true
                    errors.push field: field, error: validatorRes if errors
        return !hasErrors


module.exports = Schema