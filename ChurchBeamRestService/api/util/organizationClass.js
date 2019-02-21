var db = require('../util/db')

class Organization {
    static get (orgId) {
        var sql = `SELECT * FROM organization WHERE id =${orgId}`
        
        return new Promise((resolve, reject) => {
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    if (result.length == 0) {
                        resolve()
                    } else {
                        resolve(result[0])
                    }
                }
            })
        })
    
    }
}

module.exports = Organization