_ = require 'underscore'
Util = require './util'

class Validator
    @required: (val) ->
        val isnt null

    @numeric: (val) ->
        if _.isString(val)
            return /^\d+$/.test(val)
        else if _.isNumber(val)
            return true
        return false

    @min: (val, threshold) ->
        val >= threshold

    @max: (val, threshold) ->
        val <= threshold

    @set: (val, allowed) ->
        _.indexOf(allowed, val) != -1

    @preset: (val, name) ->
        @['_preset' + Util.ucfirst(name)](val)

    @_presetInt: (val) ->
        @numeric(val) and @max(val, 2147483647) and @min(val, -2147483648)

    @_presetTinyint: (val) ->
        @numeric(val) and @max(val, 127) and @min(val, -128)

    @string: (val) ->
        _.isString(val) or _.isNumber(val)

    @len: (val, len) ->
        @string(val) and val.toString().length is len

    @maxLen: (val, len) ->
        @string(val) and val.toString().length <= len

    @minLen: (val, len) ->
        @string(val) and val.toString().length >= len

    @regexp: (val, pattern) ->
        pattern.test(val)


module.exports = Validator