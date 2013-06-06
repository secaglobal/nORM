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
            .setOffset(@_offset)
            .setOrder(@_order)
            .compose()

        @_proxy.perform(query)

    save: (models, fillId = true) ->
        deferred = Q.defer()
        onUpdate = []
        onInsert = []
        promises = []

        models.map (model) ->
            model.get('id') or onInsert.push model
            model.hasChanged() and model.get('id') and onUpdate.push model

        @_updateModels(onUpdate, promises) if onUpdate.length
        @_insertModelsAndFillIds(onInsert, promises) if onInsert.length and fillId
        @_insertModels(onInsert, promises) if onInsert.length and not fillId


        Q.allResolved(promises).then (promises) ->
            promises.forEach (promise) ->
                if not promise.isFulfilled()
                    deferred.reject promise.valueOf().exception
                    return
            deferred.resolve()

        deferred.promise


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
        myKey = config.myField || 'id'
        theirKey = config.theirField || 'id'

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
        myKey = config.myField || 'id'
        theirKey = config.theirField || 'id'

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
                col.reset(_.where(rows, filters))

    fillManyToManyRelation: (models, relation) ->
        models = new Collection(models) until models instanceof Collection
        self = @

        model = models.first().constructor
        config = models.first()[relation].config
        crosstable = [config.use.TABLE, model.TABLE].sort().join('__')
        myKey = config.myField || 'id'
        theirKey = config.theirField || 'id'

        ids = _.filter models.pluck(myKey), (v) -> v > 0
        filters = {}
        filters[model.TABLE] = {$in: ids}

        crossvalues = []

        @getProxy().perform(
          @_builder(crosstable).setFilters(filters).compose()
        ).then (rows) ->
            ids = _.filter _.pluck(rows, config.use.TABLE), (v) -> v > 0
            filters = {}
            filters[theirKey] = {$in: ids}
            crossvalues = _.groupBy(rows, (v) -> v[model.TABLE])

            self.getProxy().perform(
              self._builder(config.use.TABLE).setFilters(filters).compose()
            )
        .then (rows) ->
            models.forEach (m) ->
                return false if not m.get(myKey)?

                myid = m.get(myKey)
                options = {model: config.use}

                if not crossvalues[myid]?
                    m.setRelation relation, new Collection([], options)
                    return

                theirIds = _.pluck(crossvalues[myid], config.use.TABLE)

                filters = {}
                filters[theirKey] = {$in: theirIds}
                related = _.filter rows, (v) ->
                    _.contains(theirIds, v[theirKey])

                col = new Collection(related, options)
                m.setRelation relation, col

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

            promises.push \
                @getProxy().perform \
                    @_builder(table)
                        .insertValues(values)
                        .setFields(fields)
                        .compose()

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

            promises.push \
                @getProxy().perform \
                    @_builder(table)
                        .insertValues(values)
                        .setFields(fields)
                        .compose()

    _insertModelsAndFillIds: (models, promises) ->
        table = models[0].constructor.TABLE

        groups = _.groupBy models, (model) ->
            return _.keys(model.attributes).sort().join(';')

        for model in models
            fields = model.keys()
            values = []

            for field in fields
                values.push model.get(field)

            promises.push \
                @getProxy().perform(
                    @_builder(table)
                        .insertValues([values])
                        .setFields(fields)
                        .compose()

                ).then @_wrapInsertCallback(model)

    _wrapInsertCallback: (model) ->
        (result) ->
            model.set({id: result.insertId})

    _updateModels: (models, promises) ->
        table = models[0].constructor.TABLE

        for model in models
            promises.push \
                @getProxy().perform \
                    @_builder(table)
                    .updateFields(model.changed)
                    .setFilters({id: model.get('id')})
                    .compose()

    _builder: (table) ->
        throw 'not implemented'

module.exports = DBDataRequest;