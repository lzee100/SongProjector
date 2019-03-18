const express = require('express');
const router = express.Router();
const print = require('../util/print')
const UserClass = require('../util/userClass')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

// DELETE FROM localhostchurchbeam.user WHERE userToken = ''

router.get('/', (req, res , next) => {
    print.print('in user init')

    let userToken = req.query.userToken
    let appInstallToken = req.query.appInstallToken

    print.print('userToken', userToken)
    print.print('appInstallToken', appInstallToken)

    if (userToken, appInstallToken) {
        getUser(userToken)
        .then(user => {
            if (!user) {
                print.print('user not found')
                res.status(400).json({
                    error: "no user found"
                })
            } else if (user.appInstallToken == appInstallToken) {
                res.status(200).json([user])
            } else {
                res.status(424).json({
                    error: "has install on other device"
                })
            }
        })
    } else {m
        print.print('no usertoken and devicetoken')
        res.status(400).json({
            error: "no usertoken and appid"
        })
    }
})

router.post('/', (req, res , next) => {
    print.print('in post user init')

    if (req.body[0] && req.body[0].organizationTitle) {
        postUserInitInfo(req.body[0], res)
    } else if (req.body[0] && req.body[0].inviteToken){
        postInvitedUser(req.body[0])
        .then(users => {
            res.status(200).json(users)
        })
        .catch(err => {
            if (err.statusCode) {
                res.status(404).json()
            } else {
                res.status(500).json(err)
            }
        })
    } else {
        let userToken = req.query.userToken
        let appInstallToken = req.query.appInstallToken
        let isNewInstall = req.query.isNewInstall
    
        print.print('userToken', userToken)
        print.print('appInstallToken', appInstallToken)
        
        if (userToken, appInstallToken, isNewInstall) {
            if (isNewInstall == 0) {
                updateUser(userToken, appInstallToken)
                .then(user => {
                    if (!user) {
                        print.print('user not found')
                        res.status(400).json({
                            error: "no user found"
                        })
                    } else {
                        res.status(200).json([user])
                    }
                })
                .catch(err => {
                    res.status(500).json(err)
                })
            } else {
                postUser(userToken, appInstallToken)
                .then(user => { 
                    res.status(201).json([user])
                })
            }
        } else {
            print.print('no userToken and appInstallToken')
            res.status(400).json({
                error: "no usertoken and appInstallToken"
            })
        }
    }
   
})

function postUserInitInfo(userInitInfo, res) {
    let body = userInitInfo

    let organizationTitle = body.organizationTitle
    let contractId = body.contractId
    let phoneNumber = body.phoneNumber
    let userName = body.userName
    let hasApplePay = body.hasApplePay
    let appInstallToken = body.appInstallToken
    let userToken = body.userToken

    postOrganization(organizationTitle)
    .then(function(organizationId) {
        return new Promise((resolve, reject) => {
            UserClass.postUser(organizationId, userToken, appInstallToken, userName)
            .then(function(user) {
                var organizationIdUser = {
                    organizationId: organizationId,
                    user: user
                }
                resolve(organizationIdUser)
            })
            .catch(err => {
                reject(err)
            })
        })
    })
    .then(function(organizationUser) {
        postContractLedger(contractId, organizationUser.organizationId, userName, phoneNumber, hasApplePay, organizationUser.user.id)
        .then(function() {
            res.status(201).json([organizationUser.user])
        })
        .catch(err => {
            res.status(500).json(err)
        })
    })
    .catch(err => {
        res.status(500).json(err)
    })
}

function postInvitedUser(user) {
    const getUserForInviteToken = function(inviteToken) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM user WHERE inviteToken = '${inviteToken}'`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    if (result.length == 0) {
                        reject()
                    } else {
                        resolve(result[0])
                    }
                }
            }) 
        })
    }

    const updateUser = function(dbUser, newUser) {
        return new Promise((resolve, reject) => {
            let sql = `UPDATE user SET appInstallToken = '${newUser.appInstallToken}', userToken = '${newUser.userToken}' WHERE id = '${dbUser.id}'`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(dbUser)
                }
            })
        })
    }

    print.print('inviteToken', user.inviteToken)
    return new Promise((resolve, reject) => {
        getUserForInviteToken(user.inviteToken)
        .then(function(dbUser) {
            print.print('dbuser', dbUser)
            updateUser(dbUser, user)
            .then(dbUser => {
                return UserClass.get(dbUser.id)
            })
            .then(user => {
                resolve([user])
            })
            .catch(err => {
                reject(err)
            })
        })
        .catch(err => {
            if(err) {
                reject(err)
            } else {
                var myErr = {
                    statusCode: 404
                }
                reject(myErr)
            }
        })
    })

}

function getUser(token) {

    var getUser = new Promise((resolve, reject) => {
        let sql = `SELECT * FROM user WHERE userToken = '${token}' AND deletedAt IS NULL`
        print.print(sql)
        db.query(sql, (err, result) => {
            if (err) {
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

    var getFullUser = function(user) {
        return new Promise((resolve, reject) => {
            if (!user) {
                resolve()
            } else {
               UserClass.get(user.id)
               .then(user => {
                   resolve(user)
               })
               .catch(err => {
                   reject(err)
               })
            }
        })
    }

    return new Promise((resolve, reject) => {
        getUser
        .then(getFullUser)
        .then(function(user) {
            resolve(user)
        })
        .catch(err => {
            reject(err)
        })
    })
}

function updateUser(userToken, appInstallToken) {
    return new Promise((resolve, reject) => {
        let sql = `UPDATE user SET appInstallToken = '${appInstallToken}' WHERE userToken = '${userToken}'`
        print.print(sql)
        db.query(sql, (err, result) => {
            if (err) {
                reject(err)
            } else {
                getUser(userToken)
                .then(user => {
                    resolve(user)
                })
                .catch(err => {
                    reject(err)
                })
            }
        })
    })
}

function postUser(userToken, appInstallToken) {
    print.print('in post new invite user')

    const insertUser = function(oldUserAndRole) {
        return new Promise((resolve, reject) => {
            let sql = `INSERT INTO user (appInstallToken, userToken, title) VALUES('${appInstallToken}', '${userToken}', '${oldUserAndRole.oldUser.title}')`
            print.print(sql)
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    UserClass.get(result.insertId)
                    .then(user => {
                        var newUser = user
                        newUser.roleId = oldUserAndRole.userHasRole.role_id
                        let newUserAndRole = {
                            oldUserAndRole: oldUserAndRole,
                            newUser: user
                        }
                        resolve(newUserAndRole)
                    })
                    .catch(err => {
                        reject(err)
                    })
                }
            })
        })
    }

    const getUserHasRole = function(oldUser) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM user_has_role WHERE user_id = '${oldUser.id}'`
            print.print(sql)
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    var oldUserAndRole = {
                        oldUser: oldUser,
                        userHasRole: result[0]
                    }
                    resolve(oldUserAndRole)
                }
            })
        })
    }

    const insertUserHasRole = function(newUserAndRole, newUserId) {
        return new Promise((resolve, reject) => {
            let sql =  `INSERT INTO user_has_role (user_id, role_id) VALUES('${newUserId}', '${newUserAndRole.oldUserAndRole.userHasRole.role_id}')`
            print.print(sql)
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(newUserAndRole)
                }
            })
        })
    }

    return new Promise((resolve, reject) => {
        var nothing
        UserClass.get(nothing, nothing, userToken)
        .then(user => {
            return getUserHasRole(user)
        })
        .then(oldUserAndRole => {
           return insertUser(oldUserAndRole)
        })
        .then(newUserAndRole => {
            return insertUserHasRole(newUserAndRole, newUserAndRole.newUser.id)
        })
        .then(newUserAndRole => {
            resolve(newUserAndRole.newUser)
        })
        .catch(err => {
            reject(err)
        })
    })

}

function postOrganization(name) {

    return new Promise((resolve, reject) => {
        let sql = `INSERT INTO organization (name) VALUES("${name}")`
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

}

function postContractLedger(contractId, organizationId, userName, phoneNumber, hasApplePay, userId) {

    var getContractLedger = function(contractLedgerId) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM contractLedger WHERE id=("${contractLedgerId}")`
            db.query(sql, (err, result) => {
                if (err) {
                    print.print('error gettoing contractLedger', err)
                    reject(err)
                } else {
                    print.print('newLedger', result[0])
                    resolve(result[0])
                }
            })
        })
    }

    return new Promise((resolve, reject) => {

        let sql = `INSERT INTO contractLedger (contract_id, organization_id, userName, phoneNumber, hasApplePay, user_id) VALUES(${contractId}, ${organizationId}, '${userName}', '${phoneNumber}', ${hasApplePay}, ${userId})`

        db.query(sql, (err, result) => {
            if (err) {
                print.print('error inserting contractLedger', err)
                reject(err)
            } else {
                print.print('insert id', result.insertId)
                getContractLedger(result.insertId)
                .then(function(contractLedger) {
                    resolve(contractLedger)
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

module.exports = router;