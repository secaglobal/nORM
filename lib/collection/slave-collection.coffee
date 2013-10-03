_ = require 'underscore'
Collection = require './collection'
Exception = require '../exception'


class SlaveCollection extends Collection
    save: () ->
        super
            .then (col)->
                filters = col.config.filters

                if not _.isObject(filters) or _.isEmpty(filters)
                    throw new Exception 'SLAVE_COL__NO_FILTERS'

                filters['id'] = $nin: col.pluck('id') if not col.isEmpty()
                new Collection(filters: filters, model: col.config.model).load()
            .then (col) ->
                col.delete() if not col.isEmpty()

    assignParentModel:  (model) ->
        fieldName = model.constructor.schema.defaultFieldName
        id = model.id
        @each (i) -> i[fieldName] = id
        @addFilter(fieldName, id)
        @

module.exports = SlaveCollection

