Q = require 'q'
_ = require 'underscore'
Entity = require("./entity");
Collection = require("./collection");

class Model extends Entity
    constructor: (attributes) ->
        super()
        @original = attributes

        for attr, value of attributes
            if _.isArray value
                value = new Collection(value, {model: @self.schema.fields[attr].type})

            @[attr] = value

    require: () ->
        collection = @collection or new Collection([@], {model: @self})
        collection.require.apply collection, arguments

    @getProxyAlias: () ->
        return @schema.proxy

module.exports = Model;