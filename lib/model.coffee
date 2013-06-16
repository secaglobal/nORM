Q = require 'q'
_ = require 'underscore'
Util = require './util'
IModel = require("./imodel");
Collection = require("./collection");

class Model extends IModel
    constructor: (attributes) ->
        super()
        @schema = @self.schema
        @original = {}

        for attr, value of attributes
            if _.isArray value
                value = new Collection(value, {model: @self.schema.fields[attr].type})
            else if Util.isHashMap(value) and @self.schema.fields[attr].type.prototype instanceof Model
                value = new @self.schema.fields[attr].type value

            @[attr] = value
            @original[attr] = value

    require: () ->
        me = @
        collection = @collection or new Collection([@], {model: @self})
        collection.require.apply(collection, arguments).then(() -> return me)

    hasChanges: () ->
        !_.isEmpty @getChangedAttributes()

    getChangedAttributes: () ->
        changes = {}
        fields = @self.schema.fields
        for field, params of fields
            changes[field] = @[field] if @original[field] != @[field]
        return if _.isEmpty(changes) then false else changes

    @getProxyAlias: () ->
        return @schema.proxy

module.exports = Model;