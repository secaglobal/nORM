# Part = new Schema {},
#   title: String

# CatHasChild = new Schema {},
#   parentId: Number
#   childId: Number
#   type: Number
#   child: {type: Cat, field: childId}
#   parent: {type: Cat, field: parentId}
#
# Cat = new Schema {table: 'Table', proxy: 'mongo'},
#   title: String
#   age: {type: Number, min: 100, default: 101}
#   teacherId: Number
#   childs: [{type: Cat, myltiple: true, throught: {type: CatHasChild, field:parentId, use: 'parent'}}]    #many to many
#   parents: [{type: Cat, myltiple: true}                                                                  #many to many
#   jobs: [Cat]                                                                                            #one to many
#   teacher: Cat,                                                                                          #many to one
#   parts: [Part]
#


class Schema
    constructor: (@_options, @_structure) ->

    isRelation: () ->
        @

    getProxy: () ->
        @

    validate: () ->
        @
