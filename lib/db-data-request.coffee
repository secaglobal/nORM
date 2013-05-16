DataRequest = require './data-request'
QueryBuilder = require './mysql/query-builder'
_ = require 'underscore'
Q = require 'q'

class DBDataRequest extends DataRequest
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
    ids = _.filter _.pluck(models, 'id'), (v) -> v > 0

    @getProxy().perform \
      @_builder(table).setType(QueryBuilder.TYPE__DELETE).setFilters({id: {$in: ids}}).compose()

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
          @_builder(table).insertValues(values).setFields(fields).compose()

  _updateModels: (models, promises) ->
    table = models[0].constructor.TABLE

    for model in models
      promises.push \
        @getProxy().perform \
          @_builder(table).updateFields(model.changed).setFilters({id: model.get('id')}).compose()

  _builder: (table) ->
    new QueryBuilder().setTable(table)

module.exports = DBDataRequest;