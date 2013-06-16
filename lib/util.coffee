module.exports.isArray = (arr) ->
    !!arr && arr.constructor == Array

module.exports.isHashMap = (o) ->
    !!o && o.constructor == Object

module.exports.ucfirst = (str) ->
    f = str.charAt(0).toUpperCase()
    f + str.substr(1, str.length-1)

module.exports.lcfirst = (str) ->
    f = str.charAt(0).toLowerCase()
    f + str.substr(1, str.length-1)
