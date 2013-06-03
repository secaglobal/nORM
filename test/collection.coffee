MysqlProxy = require "#{LIBS_PATH}/mysql/proxy"
Model = require "#{LIBS_PATH}/model"
Collection = require "#{LIBS_PATH}/collection"
DataProvider = require "#{LIBS_PATH}/data-provider"

class User extends Model
    @TABLE: 'User'


describe '@Collection', () ->

    beforeEach (done) ->
        loadFixtures({
            User: [
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

            col = new Collection(models, {model: User})
            col.save().fail(done).then () ->
                new Collection([], {model: User}).load().fail(done).then (c) ->
                    try
                        c.length.should.be.equal 5
                        expect(c.findWhere({name: 'Lev'})).be.ok
                        expect(c.findWhere({name: 'Flora'})).be.ok
                        expect(col.findWhere({name: 'Lev'}).get('id')).be.equal c.findWhere({name: 'Lev'}).get('id')
                        expect(col.findWhere({name: 'Flora'}).get('id')).be.equal c.findWhere({name: 'Flora'}).get('id')

                        done()
                    catch e
                        done e

        it 'should save existed models', (done) ->
            new Collection([], {model: User}).load().fail(done).then (col) ->
                col.findWhere({name: 'Mike'}).set({name: 'Fill'})
                col.save().fail(done).then () ->
                    new Collection([], {model: User}).load().fail(done).then (col) ->
                        try
                            col.length.should.be.equal 3
                            expect(col.findWhere({name: 'Mike'})).be.not.ok
                            expect(col.findWhere({name: 'Fill'})).be.ok
                            done()
                        catch e
                            done e

    describe '#delete', () ->
        it 'should delete models', (done) ->
            new Collection([], {model: User}).load().fail(done).then (col) ->
                col.delete().fail(done).then () ->
                    new Collection([], {model: User}).load().fail(done).then (c) ->
                        try
                            col.length.should.be.equal 0
                            c.length.should.be.equal 0
                            done()
                        catch e
                            done e

    describe '#load', () ->
        it 'should load using filters', (done) ->
            new Collection([], {model: User, filters: {name: 'Marge'}}).load().fail(done).then (col) ->
                try
                    col.length.should.be.equal 1
                    expect(col.first().get('name')).be.equal 'Marge'
                    expect(col.first().get('id')).be.equal 8
                    done()
                catch e
                    done e

        it 'should load using limit', (done) ->
            new Collection([], {model: User, limit: 2}).load().fail(done).then (col) ->
                try
                    col.length.should.be.equal 2
                    done()
                catch e
                    done e

        it 'should load using offset', (done) ->
            new Collection([], {model: User, limit: 10, offset: 2}).load().fail(done).then (col) ->
                try
                    col.length.should.be.equal 1
                    done()
                catch e
                    done e

        it 'should load using order', (done) ->
            new Collection([], {model: User, order: {id: -1}}).load().fail(done).then (col) ->
                try
                    col.first().get('id').should.be.equal 8
                    done()
                catch e
                    done e




