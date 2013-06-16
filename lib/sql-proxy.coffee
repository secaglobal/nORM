DBProxy = require('./db-proxy')

class SQLProxy extends DBProxy
    getReadConnection: () ->
        throw 'not implemented yet'

    getWriteConnection: () ->
        throw 'not implemented yet'

module.exports = SQLProxy