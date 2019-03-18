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

router.get('/', (req, res , next) => {
    print.print('in get users all for org')
    let organizationId = req.get("organizationId")
    print.print('orgid', organizationId)
   
    UserClass.getUsers(organizationId)
    .then(users => {
        print.print(users)
        res.status(200).json(users)
    })
    .catch(err => {
        res.status(500).json(err)
    })
})

router.get('/:userId', (req, res , next) => {

    let userId = req.params.userId
 
    if (!userId) {
        res.status(400).json({
            error: "No correct user identifier send"
        })
    }

    UserClass.get(userId)
    .then(user => {
        print.print('user returned: ', user)
        res.status(200).json([user])
    })
    .catch(err => {
        res.status(500).json(err)
    })
   
})

router.post('/', (req, res , next) => {

    var newUsers = req.body
    print.print('post user ---------------------------------------', newUsers)

    newUsers.map(user => delete user.id)

    Promise.all(newUsers.map(user => postUser(user)))
    .then(users => {
        print.print('in result function ----------------------', users)
        res.status(201).json(users)
    })
    .catch(err => {
        print.print('in err function ----------------------', err)
        res.status(500).json(err)
    })

})

router.put('/', (req, res , next) => {
    console.log('in update user')
    let newUsers = req.body;

    Promise.all(newUsers.map(user => putUser(user)))
    .then(users => {
        print.print('in put cluster 201', users)
        res.status(201).json(users)
    })
    .catch(err => {
        print.print('in put cluster 500', err)
        res.status(500).json(err)
    })
    
})

router.delete('/', (req, res , next) => {
    console.log('in delete user')
    const users = req.body

    if (req.body[0]) {
        const user = req.body[0]
        const date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
        let sql = `UPDATE user SET deletedAt = '${date}' WHERE id = ${user.id}`
        db.query(sql, (err, result) => {
            if (err) {
                res.status(500).json(err)
            } else {
                UserClass.get(user.id)
                .then(user => {
                    res.status(201).json([user])
                })
            }
        })
    }
    
})

function postUser(user) {
    var newUser = user
    let roleId = newUser.roleId
    delete newUser.roleId

    var insertUser = new Promise((resolve, reject) => {
        let sql = `INSERT INTO user SET ?`
        db.query(sql, user, (err, result) => {
            if (err) {
                reject(err)
            } else {
                resolve(result.insertId)
            }
        })
    })
    
    var insertUserHasRole = function(userId) {
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

function putUser(user) {
    var newUser = user
    delete newUser.title

    return new Promise((resolve, reject) => {
        let sql = `UPDATE user SET ? WHERE id =${user.id}`
        db.query(sql, [user], (err, result) => {
            if (err) {
                reject(err)
            } else {
                resolve(result)
            }
        })
    })
}


module.exports = router;