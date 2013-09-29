Q = require 'q'
_ = require 'underscore'
Util = require './util'
IModel = require "./imodel"
Collection = require "./collection/collection"
SlaveCollection = require "./collection/slave-collection"

class Model extends IModel
    constructor: (attributes) ->
        super()
        @schema = @self.schema
        @original = {}
        @_isSyncedWithDB = false

        for attr, value of attributes
            attrConf = @self.schema.fields[attr]
            attrType = attrConf and attrConf.type

            if _.isArray value
                colType = attrConf.dependent and SlaveCollection or Collection
                value = new colType(value, {model: attrType})
            else if Util.isHashMap(value) and attrType.prototype instanceof Model
                value = new attrType value

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

    hasChanges: (sync = false) ->
        !_.isEmpty @getChangedAttributes(sync)

    getChangedAttributes: (sync = false) ->
        changes = {}
        fields = @self.schema.keys
        for field in fields
            if not sync or @.isSyncedWithDB()
                changes[field] = @[field] if @original[field] != @[field]
            else
                changes[field] = @[field] if typeof @[field] isnt 'undefined'
        return if _.isEmpty(changes) then false else changes

    validate: (errors = null, recurcive = false) ->
        @self.schema.validate(@, errors, recurcive);

    save: (recursive = false) ->
        _this = @
        new Collection([@]).save(recursive).then () -> _this

    delete: () ->
        @collection.remove(@) if @collection
        new Collection([@]).delete()

    setSyncedWithDB: (state = true) ->
        @_isSyncedWithDB = state

    isSyncedWithDB: () ->
        @_isSyncedWithDB

    @getProxyAlias: () ->
        return @schema.proxy

module.exports = Model;