MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
DataProvider = require "#{LIBS_PATH}/data-provider"

Person = require('./models')['Person']

describe '@Collection', () ->

    beforeEach (done) ->
        loadFixtures({
            Person: [
                {id: 1, name: 'Mike'},
                {id: 7, name: 'Denis'},
                {id: 8, name: 'Marge'},
            ]
        }).then(() -> done()).fail(done)

    describe '#save', () ->
        it 'should save new models', (done) ->
            models = [
                {name: "Lev"},
                {name: "Flora"}
            ]

            col = new Collection(models, {model: Person})

            col.save().fail(done).then () ->
                return new Collection([], {model: Person}).load()
            .then (c) ->
                try
                    c.length.should.be.equal 5
                    expect(c.findWhere({name: 'Lev'})).be.ok
                    expect(c.findWhere({name: 'Flora'})).be.ok
                    expect(col.findWhere({name: 'Lev'}).id).be.equal c.findWhere({name: 'Lev'}).id
                    expect(col.findWhere({name: 'Flora'}).id).be.equal c.findWhere({name: 'Flora'}).id

                    done()
                catch e
                    done e
            .fail(done)

        it 'should save existed models', (done) ->
            new Collection([], {model: Person}).load()
            .then (col) ->
                col.findWhere({name: 'Mike'}).name = 'Fill'
                col.save()
            .then () ->
                new Collection([], {model: Person}).load().fail(done).then (col) ->
                    try
                        col.length.should.be.equal 3
                        expect(col.findWhere({name: 'Mike'})).be.not.ok
                        expect(col.findWhere({name: 'Fill'})).be.ok
                        done()
                    catch e
                        done e
            .fail(done)

    describe '#delete', () ->
        it 'should delete models', (done) ->
            new Collection([], {model: Person}).load()
                .then (col) -> col.delete()
                .then () -> new Collection([], {model: Person}).load()
                .then (c) ->
                    try
                        col.length.should.be.equal 0
                        c.length.should.be.equal 0
                        done()
                    catch e
                        done e
                .fail(done)

    describe '#load', () ->
        it 'should load using filters', (done) ->
            new Collection([], {model: Person, filters: {name: 'Marge'}}).load()
                .then (col) ->
                    try
                        col.length.should.be.equal 1
                        expect(col.first().name).be.equal 'Marge'
                        expect(col.first().id).be.equal 8
                        done()
                    catch e
                        done e
                .fail(done)

        it 'should load using limit', (done) ->
            new Collection([], {model: Person, limit: 2}).load()
                .then (col) ->
                    try
                        col.length.should.be.equal 2
                        done()
                    catch e
                        done e
                .fail(done)

        it 'should load using offset', (done) ->
            new Collection([], {model: Person, limit: 10, offset: 2}).load()
                .then (col) ->
                    try
                        col.length.should.be.equal 1
                        done()
                    catch e
                        done e
                .fail(done)

        it 'should load using order', (done) ->
            new Collection([], {model: Person, order: {id: -1}}).load()
                .then (col) ->
                    try
                        col.first().id.should.be.equal 8
                        done()
                    catch e
                        done e
                .fail(done)




