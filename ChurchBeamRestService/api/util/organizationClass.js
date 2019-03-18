var db = require('../util/db')

class Organization {
    static get (orgId) {
        
        return new Promise((resolve, reject) => {
            getOrganization(orgId)
            .then(getRoles)
            .then(getContractLedgers)
            .then(organization => {
                resolve(organization)
            })
            .catch(err => {
                reject(err)
            })
        })
    
    }
}

function getOrganization(orgId) {
    return new Promise((resolve, reject) => {
        var sql = `SELECT * FROM organization WHERE id =${orgId}`
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

function getRoles(organization) {
    return new Promise((resolve, reject) => {
        var sql = `SELECT * FROM role WHERE organization_id =${organization.id}`
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                var org = organization
                org.roles = result
                resolve(org)
            }
        })
    })
}

function getContractLedgers(organization) {
    return new Promise((resolve, reject) => {
        var sql = `SELECT * FROM contractLedger WHERE organization_id =${organization.id}`
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                var org = organization
                org.contractLedgers = result
                resolve(org)
            }
        })
    })
}



module.exports = Organization