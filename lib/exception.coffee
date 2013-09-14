class Exception extends Error
    constructor: (@code, @message, @params) ->
        @message = @code if not @message

module.exports = Exception