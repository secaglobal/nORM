DataRequest = require './data-request'
QueryBuilder = require './mysql/query-builder'
_ = require 'underscore'

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


  delete: (models) ->

  _insertModels: (models, promises) ->
    groups = _.groupBy models, (model) ->
      return _.keys(model.attributes).sort().join(';')

    for key, group of groups
      fields = key.splite(';')
      values = []
      for model in group
        value = []
        values.push value
        for field in fields
          value.push model.get(field)

      console.log new QueryBuilder().insertValues(values).setFields(fields).compose()
      promises.push(
        @getProxy().perform new QueryBuilder().insertValues(values).setFields(fields).compose()
      )


#    for model in models
#      fields = _.keys model.changed
#      fields.sort()
#
#      sets[fields] or (sets[fields] = [])


  _updateModels: (models, promises) ->
    for model in models
      console.log new QueryBuilder().updateFields(models.changed).setFilters({id: model.get('id')}).compose()
      promises.push(
        @getProxy().perform new QueryBuilder().updateFields(models.changed).setFilters({id: model.get('id')}).compose()
      )

module.exports = DBDataRequest;