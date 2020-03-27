
var db = require('../util/db')

class Secret {
    static getSecret = function() {
        return new Promise((resolve, reject) => {
            let sql = `select * from uploadSecret`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result[0])
                }
            })
         })
    }

    static isSecretValid = function(secret) {
        return new Promise((resolve, reject) => {
            let sql = `select * from uploadSecret`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result[0].secret == secret)
                }
            })
         })
    }
}

module.exports = Secret;


