Collection = require './collection'

class SyncedCollection extends Collection
    constructor: (models, params) ->
        col = new Collection models, params
        col.setModelsSyncedWithDB()
        return col


module.exports = SyncedCollection