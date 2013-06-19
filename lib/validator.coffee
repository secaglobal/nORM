_ = require 'underscore'
Util = require './util'

class Validator
    @numeric: (val) ->
        if _.isString(val)
            return /^\d+$/.test(val)
        else if _.isNumber
            return true
        return false

    @min: (val, threshold) ->
        val >= threshold

    @max: (val, threshold) ->
        val <= threshold

    @enum: (val, allowed) ->
        console.log allowed, val
        _.indexOf(allowed, val) != -1


module.exports = Validator