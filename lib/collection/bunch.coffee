Collection = require './collection'

class Bunch extends Collection
    save: () ->
        super
        @_request.saveManyToManyRelations(@config.parent, @, @config.relation)

    delete: () ->
        @reset([])
        @save()

module.exports = Bunch

