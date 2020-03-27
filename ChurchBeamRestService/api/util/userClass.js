var db = require('../util/db')
var print = require('../util/print')


class UserClass {

    /// returns 1 user, not an array
    static get (userId, appInstallToken, userToken) {

        var getUser = function(userId, appInstallToken, userToken) {
            var sql = ""
            if (userId) {
                sql = `SELECT * FROM user WHERE id = ${userId}`
            } else if (appInstallToken){ 
                sql = `SELECT * FROM user WHERE appInstallToken = '${appInstallToken}'`
            } else {
                sql = `SELECT * FROM user WHERE userToken = '${userToken}'`
            }
            print.print('before query')
            return new Promise((resolve, reject) => {
                db.query(sql, (err, result) => {
                    print.print('after query')
                    if(err) {
                        print.print('error', err)
                        reject(err)
                    } else {
                        if (result.length == 0) {
                            reject({
                                error: "No user found"
                            })
                        } else {
                            resolve(result[0])
                        }
                    }
                })
            })
        }
    
        var getRoles = function(user) {
            const sql = `SELECT 
            R.id, R.title, R.organization_id, R.createdAt, R.updatedAt, R.deletedAt 
            FROM role as R 
            left join user_has_role as UR on R.id = UR.role_id 
            WHERE UR.user_id = ${user.id}`
    
            return new Promise((resolve, reject) => {
                db.query(sql, (err, result) => {
                    if(err) {
                        reject(err)
                    } else {
                        if (result.length == 0) {
                            resolve(user)
                        } else {
                            var newUser = user
                            newUser.roleId = result[0].id
                            resolve(newUser)
                        }
                    }
                })
            })
        }
    
        return new Promise((resolve, reject) => {
            getUser(userId, appInstallToken, userToken)
            .then(getRoles)
            .then(user => {
                resolve(user)
            })
            .catch(err => {
                reject(err)
            })
        })
    
    }

    static getUsers(organizationId) {

        var getUsers = function(organizationId) {
            return new Promise((resolve, reject) => {
                const sql = `SELECT U.id, U.title, U.appInstallToken, U.userToken, U.inviteToken, U.createdAt, U.updatedAt, U.deletedAt 
                FROM user as U 
                left join user_has_role as UR on U.id = UR.user_id 
                left join role as R on R.id = UR.role_id 
                left join organization  as O on R.organization_id = O.id 
                WHERE O.id = ${organizationId}`

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

        var getRoles = function(user) {
            const sql = `SELECT 
            R.id, R.title, R.organization_id, R.createdAt, R.updatedAt, R.deletedAt 
            FROM role as R 
            left join user_has_role as UR on R.id = UR.role_id 
            WHERE UR.user_id = ${user.id}`
    
            return new Promise((resolve, reject) => {
                db.query(sql, (err, result) => {
                    if(err) {
                        reject(err)
                    } else {
                        if (result.length == 0) {
                            resolve(user)
                        } else {
                            var newUser = user
                            newUser.roleId = result[0].id
                            resolve(newUser)
                        }
                    }
                })
            })
        }

        return new Promise((resolve, reject) => {
            getUsers(organizationId)
            .then(users => {
                Promise.all(users.map(user => getRoles(user)))
                .then(users => {
                    resolve(users)
                })
                .catch(err => {
                    reject(err)
                })
            })
            .catch(err => {
                reject(err)
            })
        })

    }

    static postEmptyUser() {
    
        var insertUser = new Promise((resolve, reject) => {
            let sql = `INSERT INTO user`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result.insertId)
                }
            })
        })

        var insertUserHasRole = function(userId) {
            return new Promise((resolve, reject) => {
                print.print(`INSERT INTO user_has_role VALUES('${userId}', '${roleId}')`)
                let sql = `INSERT INTO user_has_role VALUES('${userId}', '${roleId}')`
                db.query(sql, (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve(userId)
                    }
                })
            })
        }
    
        return new Promise((resolve, reject) => {
            insertUser
            .then(insertUserHasRole)
            .then(function(userId) {
                UserClass.get(userId)
                .then(user => {
                  resolve(user)
                })
                .catch(err => {
                    reject(err)
                })
            })
            .catch(err => {
                reject(err)
            })
        })
    
    
    }

    static postUser(organizationId, userToken, appInstallToken, userName) {
        
        var insertUser = new Promise((resolve, reject) => {
            let sql = `INSERT INTO user (userToken, appInstallToken, title) VALUES('${userToken}', '${appInstallToken}', '${userName}')`
            print.print(`INSERT INTO user (userToken, appInstallToken) VALUES('${userToken}', '${appInstallToken}')`)
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result.insertId)
                }
            })
        })

        var insertUserHasRole = function(userId, roleId) {
            return new Promise((resolve, reject) => {
                print.print(`INSERT INTO user_has_role VALUES(${userId}, ${roleId})`)
                let sql = `INSERT INTO user_has_role VALUES(${userId}, ${roleId})`
                db.query(sql, (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve(userId)
                    }
                })
            })
        }
    
        return new Promise((resolve, reject) => {
            insertUser
            .then(function(userId) {
                return new Promise((resolve, reject) => {
                    postRoleIfNeeded(organizationId)
                    .then(function(role) {
                        var userRole = {
                            userId: userId,
                            roleId: role[0].id
                        }
                        resolve(userRole)
                    })
                    .catch(err => {
                        reject(err)
                    })
                })
            })
            .then(function(userRole) {
                return insertUserHasRole(userRole.userId, userRole.roleId)
            })
            .then(function(userId) {
                UserClass.get(userId)
                .then(user => {
                  resolve(user)
                })
                .catch(err => {
                    reject(err)
                })
            })
            .catch(err => {
                reject(err)
            })
        })
    
    
    }


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

module.exports = UserClass