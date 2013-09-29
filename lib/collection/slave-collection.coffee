_ = require 'underscore'
Collection = require './collection'
Exception = require '../exception'


class Slave extends Collection
    save: () ->
        super
            .then (col)->
                filters = col.config.filters

                if not _.isObject(filters) or _.isEmpty(filters)
                    throw new Exception 'SLAVE_COL__NO_FILTERS'

                filters['id'] = $nin: col.pluck('id')
                new Collection(filters: filters, model: col.config.model).load()
            .then (col) ->
                col.delete()

module.exports = Slave

