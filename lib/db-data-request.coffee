DataRequest = require './data-request'

class DBDataRequest extends DataRequest
  save: (models) ->
    onUpdate = []
    onInsert = []

    models.map (model) ->
      model.get('id') or onInsert.push model
      model.hasChanged() and model.get('id') and onUpdate.push model

  delete: (models) ->

module.exports = DBDataRequest;