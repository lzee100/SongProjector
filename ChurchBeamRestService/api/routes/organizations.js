const express = require('express')
const router = express.Router()
const print = require('../util/print')
const OrganizationClass = require('../util/organizationClass')
const UserClass = require('../util/userClass')
var db = require('../util/db')

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {

    console.log('in post organizations')

    let appId = req.query.appId
    let userId = req.query.userId
    let organizationId = req.query.organizationId

    if (organizationId) {
        OrganizationClass.get(organizationId)
        .then(organization => {
            if (organization) {
                res.status(200).json(organization)
            } else {
                res.status(204)
            }
        })
        .catch(err => {
            res.status(500).json(err)
        })
    } else {
        getOrganization(userId, appId)
        .then(organization => {
            if (organization) {
                res.status(200).json(organization)
            } else {
                res.status(204)
            }
        })
        .catch(err => {
            res.status(500).json(err)
        })
    }

})

router.post('/', (req, res , next) => {
    console.log('in post organizations')
    let object = req.body

    object.map(organization => delete organization.id)
    object.map(organization => delete organization.role)
    object.map(organization => delete organization.name)
    object.map(function(organization) {
        organization.name = organization.title
        delete organization.title
    })

    print.print('organizations: ', object)
    Promise.all(object.map(organization => postOrganization(organization)))
    .then(organizations => {
        print.print('in post organizations 201', organizations)
        res.status(201).json(organizations)
    })
    .catch(err => {
        print.print('in post organizations 500', err)
        res.status(500).json(err)
    })
    
})

router.put('/', (req, res , next) => {
    console.log('in update organizations')
    let object = req.body;

    Promise.all(object.map(organization => putOrganization(organization)))
    .then(organizations => {
        print.print('in put organizations 201', organizations)
        res.status(201).json(organizations)
    })
    .catch(err => {
        print.print('in put organizations 500', err)
        res.status(500).json(err)
    })
    
})

router.delete('/organization', (req, res , next) => {
    console.log('in delete organization')
    // delete all

})

function postOrganization(organization) {
    let contractLedger = organization.contractLedgers[0]
    print.print('contract ledger', contractLedger)
    var orgId

    const insertOrganization = new Promise((resolve, reject) => {
        let sql = `INSERT INTO organization (name) VALUES("${organization.name}")`
        db.query(sql, (err, result) => {
            if (err) {
                print.print('error inserting organization', err)
                reject(err)
            } else {
                orgId = result.insertId
                print.print('inserted orgId', result.insertId)
                resolve(result.insertId)
            }
        })
    })

    return new Promise((resolve, reject) => {
        if (!contractLedger) {
            reject(json({
                error: "`no contract ledger"
            }))
        } else {
            insertOrganization
            .then(function(organizationId) {
                var contrLedger = contractLedger
                contrLedger.organization_id = organizationId
                delete contrLedger.id
                postContractLedger(contrLedger)
                .then(postRoleIfNeeded(organizationId))
                .then(function(roles) {
                Userc
                OrganizationClass.get(organizationId)
                .then(function(organization) {
                    resolve(organization)
                })
                .catch(err => {
                    reject(err)
                })
            })
                .catch(err => {
                    reject(err)
                })
            })
            .catch(err => {
                reject(err)
            })
        }
   })
}

function postContractLedger(contractLedger) {

    return new Promise((resolve, reject) => {

        let sql = `INSERT INTO contractLedger SET ?`

        db.query(sql, [contractLedger], (err, result) => {
            if (err) {
                print.print('error inserting contractLedger', err)
                reject(err)
            } else {
                print.print('insert id', result.insertId)
                let sql = `SELECT * FROM contractLedger WHERE id=("${result.insertId}")`
                db.query(sql, (err, result) => {
                    if (err) {
                        print.print('error gettoing contractLedger', err)
                        reject(err)
                    } else {
                        print.print('newLedger', result[0])
                        resolve(result[0])
                    }
                })
            }
        })
   })
}

function postRoleIfNeeded(organizationId) {
    print.print('in post role if needed')

    var getRole = new Promise((resolve, reject) => {
        let sql = `SELECT * FROM role WHERE organization_id = ${organizationId}`
        db.query(sql, (err, result) => {
            if (err) {
                reject(err)
            } else {
                if (result.length == 1) {
                    resolve(result)
                } else {
                    resolve()
                }
            }
        })
    })

    var getNewRole = function(roleId) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM role WHERE id=${roleId}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                     resolve(result)
                }
            })
        })
    }

    var insertRole = new Promise((resolve, reject) => {
        let sql = `INSERT INTO role (organization_id, title) VALUES(${organizationId}, "default")`
        db.query(sql, (err, result) => {
            if (err) {
                reject(err)
            } else {
                getNewRole(result.insertId)
                .then(roles => {
                    resolve(roles)
                })
                .catch(err => {
                    print.print('in error result')
                    reject(err)
                })
            }
        })
    })

    return new Promise((resolve, reject) =>  {
        getRole
        .then(role => {
            if (role) {
                resolve(role)
            } else {
                insertRole
                .then(roles => {
                    resolve(roles)
                })
                .catch(err => {
                    reject(err)
                })
            }
        })
        .catch(err => {
            reject(err)
        })
    })

}

function putOrganization(organization) {
    return new Promise((resolve, reject) => {
         let sql = `UPDATE organization SET name = ? WHERE id = ${organization.id}`
 
         db.query(sql, [organization.name], (err, result) => {
             if (err) {
                 reject(err)
             } else {
                OrganizationClass.get(result.insertId)
                 .then(organization => {
                     resolve(organization)
                 })
             }
         })
    })
 }
 

function getOrganization(userId, appId) {
    var sql = `SELECT 
    O.id, 
    O.name, 
    O.createdAt, 
    O.updatedAt, 
    O.deletedAt 
    FROM organization AS O 
    LEFT JOIN role AS R on O.id = R.organization_id 
    LEFT JOIN user_has_role AS UR ON R.id=UR.role_id 
    LEFT JOIN user as U ON UR.user_id = U.id 
    WHERE `
    if (userId) {
        sql += `U.id = ${userId}`
    } else { 
        sql += `U.appId = ${appId}`
    }

    return new Promise((resolve, reject) => {
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                if (result.length == 0) {
                    resolve()
                } else {
                    resolve(result)
                }
            }
        })
    })

}

module.exports = router;