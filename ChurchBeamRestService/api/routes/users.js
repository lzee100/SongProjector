const express = require('express');
const router = express.Router();
const print = require('../util/print')
const Organization = require('../routes/organizations')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {

    let userId = req.query.userId
 
    if (!userId) {
        res.status(400).json({
            error: "No correct app identifier send"
        })
    }

    getUser(userId)
    .then(user => {
        res.status(200).json(user)
    })
    .catch(err => {
        res.status(500).json(err)
    })
})

router.post('/', (req, res , next) => {

    var newUsers = req.body
    print.print('post user ---------------------------------------', newUsers)

    let organizationID = req.get("organizationID")

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

function getUser(userId, appId) {
    var sql = ""
    if (userId) {
        sql = `SELECT * FROM user WHERE id = ${userId}`
    } else { 
        sql = `SELECT * FROM user WHERE appId = ${appId}`
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

function postUser(user) {
    var newUser = user
    delete newUser.title
    
    return new Promise((resolve, reject) => {
        let sql = `INSERT INTO user SET ?`
        db.query(sql, user, (err, result) => {
            if (err) {
                reject(err)
            } else {
                getUser(result.insertId)
                .then(user => {
                    if (user.length > 0) {
                        resolve(user[0])
                    } else {
                        reject()
                    }
                })
                .catch(err => {
                    reject(err)
                })
            }
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