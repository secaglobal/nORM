module.exports.isArray = (arr) ->
    !!arr && arr.constructor == Array

module.exports.isHashMap = (o) ->
    !!o && o.constructor == Object