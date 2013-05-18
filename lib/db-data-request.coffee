DataRequest = require './data-request'
Collection = require './collection'
QueryBuilder = require './mysql/query-builder'
_ = require 'underscore'
Q = require 'q'

#@abstract
class DBDataRequest extends DataRequest
    find: (Model) ->
        query = @_builder(Model.TABLE)
            .setFilters(@_filters or {})
            .setLimit(@_limit)
            .setOrder(@_order)
            .compose()

        @_proxy.perform(query)

    save: (models) ->
        onUpdate = []
        onInsert = []
        promises = []

        models.map (model) ->
            model.get('id') or onInsert.push model
            model.hasChanged() and model.get('id') and onUpdate.push model

        @_updateModels(onUpdate, promises) if onUpdate.length
        @_insertModels(onInsert, promises) if onInsert.length

        Q.allResolved(promises)


    delete: (models) ->
        table = models[0].constructor.TABLE
        ids = _.filter _.pluck(models, 'id'), (v) ->
            v > 0

        @getProxy().perform \
            @_builder(table)
            .setType(QueryBuilder.TYPE__DELETE)
            .setFilters({id: {$in: ids}})
            .compose()

    fillManyToOneRelation: (models, relation) ->
        models = new Collection(models) until models instanceof Collection

        config = models.first()[relation].config
        myKey = config.myKey || 'id'
        theirKey = config.theirKey || 'id'

        ids = _.filter models.pluck(myKey), (v) -> v > 0
        filters = {}
        filters[theirKey] = {$in: ids}

        @getProxy().perform(
          @_builder(config.use.TABLE).setFilters(filters).compose()
        ).then (rows) ->
            models.forEach (m) ->
                return false if not m.get(myKey)?

                filters = {}
                filters[theirKey] = m.get(myKey)
                options = {model: config.use}
                col = new Collection([], options)
                m.setRelation relation, col
                record = _.findWhere(rows, filters)
                col.add(record) if record

    fillOneToManyRelation: (models, relation) ->
        models = new Collection(models) until models instanceof Collection

        config = models.first()[relation].config
        myKey = config.myKey || 'id'
        theirKey = config.theirKey || 'id'

        ids = _.filter models.pluck(myKey), (v) -> v > 0
        filters = {}
        filters[theirKey] = {$in: ids}

        @getProxy().perform(
          @_builder(config.use.TABLE).setFilters(filters).compose()
        ).then (rows) ->
            models.forEach (m) ->
                return false if not m.get(myKey)?

                filters = {}
                filters[theirKey] = m.get(myKey)
                options = {model: config.use}
                col = new Collection([], options)
                m.setRelation relation, col
                console.log(m.get(myKey), filters, _.where(rows, filters));
                col.reset(_.where(rows, filters))

    _insertModels: (models, promises) ->
        table = models[0].constructor.TABLE

        groups = _.groupBy models, (model) ->
            return _.keys(model.attributes).sort().join(';')

        for key, group of groups
            fields = key.split(';')
            values = []
            for model in group
                value = []
                values.push value
                for field in fields
                    value.push model.get(field)

            promises.push
            @getProxy().perform \
                @_builder(table).insertValues(values).setFields(fields).compose()

    _updateModels: (models, promises) ->
        table = models[0].constructor.TABLE

        for model in models
            promises.push
            @getProxy().perform \
                @_builder(table)
                .updateFields(model.changed)
                .setFilters({id: model.get('id')})
                .compose()

    _builder: (table) ->
        throw 'not implemented'

module.exports = DBDataRequest;