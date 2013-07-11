_ = require 'underscore'
Util = require './util'

class Validator
    required: (val) ->
        val isnt null or @error('VALIDATOR__ERROR__REQUIRE', _.toArray(arguments))

    numeric: (val) ->
        if _.isString(val)
            return true if /^\d+$/.test(val)
        else if _.isNumber(val)
            return true
        return @error('VALIDATOR__ERROR__NUMERIC', _.toArray(arguments))

    min: (val, threshold) ->
        val >= threshold or @error('VALIDATOR__ERROR__MIN', _.toArray(arguments))

    max: (val, threshold) ->
        val <= threshold or @error('VALIDATOR__ERROR__MAX', _.toArray(arguments))

    set: (val, allowed) ->
        _.indexOf(allowed, val) != -1 or @error('VALIDATOR__ERROR__SET', _.toArray(arguments))

    preset: (val, name) ->
        @['_preset' + Util.ucfirst(name)](val) or @error('VALIDATOR__ERROR__PRESET', _.toArray(arguments))

    _presetInt: (val) ->
        @_presetNumeric(val, 2147483647, -2147483648)

    _presetTinyint: (val) ->
        @_presetNumeric(val, 127, -128)

    _presetNumeric: (val, max, min) ->
        validators = [
            [@numeric, [val]],
            [@max, [val, max]],
            [@min, [val, min]],
        ]

        for test in validators
            return err if (err = test[0].apply(@, test[1])).isError
        return true

    string: (val) ->
        _.isString(val) or _.isNumber(val) or @error('VALIDATOR__ERROR__STRING', _.toArray(arguments))

    len: (val, len) ->
        (!@string(val).isError and val.toString().length is len) or @error('VALIDATOR__ERROR__LEN', _.toArray(arguments))

    maxLen: (val, len) ->
        (!@string(val).isError and val.toString().length <= len) or @error('VALIDATOR__ERROR__MAX_LEN', _.toArray(arguments))

    minLen: (val, len) ->
        (!@string(val).isError and val.toString().length >= len) or @error('VALIDATOR__ERROR__MIN_LEN', _.toArray(arguments))

    regexp: (val, pattern) ->
        pattern.test(val) or @error('VALIDATOR__ERROR__REGEXP', _.toArray(arguments))

    error: (type, params) ->
        new ValidatorError(type, params)

class ValidatorError
    constructor: (@code, @params) ->
        @isError = true

    toString: () ->
        @code

module.exports = new Validator