_ = require 'underscore'
Util = require './util'
Model = require './model'
Validator = require './validator'

class Schema
    constructor: (@name, structure) ->
        @fields = {id: {type: Number}}
        @pseudoFields = []
        @relations = []
        @dependentRelations = []
        @keys = []
        @_applyAttr attr, value for attr, value of structure
        @defaultFieldName = Util.lcfirst(name) + 'Id'

    _applyAttr: (attr, value) ->
        attrConf =
            type: value,
            dependent: false,
            collection: false,
            pseudo: false,
            m2m: false,
            external: false

        if attr is '_proxy'
            @proxy = value
            return
        else if _.isArray(value)
            attrConf.collection = true

            if  _.isArray(value[0])
                attrConf.type = value[0][0]
                attrConf.m2m = true
            else
                attrConf.type = value[0]
                attrConf.dependent = true
        else if Util.isHashMap(value)
            attrConf = value
        else if @_isPseudoField value
            attrConf.pseudo = true


        if _.isFunction(attrConf.type) and attrConf.type.prototype instanceof Model
            attrConf.external = true
            @relations.push attr
            @dependentRelations.push attr if attrConf.dependent
        else if attrConf.pseudo
            @pseudoFields.push attr
        else
            @keys.push attr

        @fields[attr] = attrConf

    _isPseudoField: (value) ->
        _.isFunction(value) and not (value.prototype instanceof Model) and not
            (value is String or value is Number or value is Date)

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
                if validator in ['collection', 'm2m', 'external', 'dependent', 'pseudo']
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