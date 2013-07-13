Q = require 'q'
_ = require 'underscore'
Util = require './util'
IModel = require("./imodel");
Collection = require("./collection");
DataProvider = require './data-provider'

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
        _this = @
        collection = @collection or new Collection([@], {model: @self})
        collection.require.apply(collection, arguments).then(() -> return _this)

    toJSON: () ->
        res = {}
        for field of @self.schema.fields
            value = @[field]
            if value?
                res[field] = value
        return res

    hasChanges: () ->
        !_.isEmpty @getChangedAttributes()

    getChangedAttributes: () ->
        changes = {}
        fields = @self.schema.fields
        for field of fields
            changes[field] = @[field] if @original[field] != @[field]
        return if _.isEmpty(changes) then false else changes

    validate: (isRecurcive = false) ->
        @self.schema.validate(@, isRecurcive);

    save: () ->
        throw err if (err = @validate()) isnt true
        DataProvider.createRequest(@self).save(new Collection([@]))

    delete: () ->
        @collection.remove(@) if @collection
        DataProvider.createRequest(@self).delete(new Collection([@]))

    @getProxyAlias: () ->
        return @schema.proxy

module.exports = Model;