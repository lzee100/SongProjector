const express = require('express');
const router = express.Router();
const print = require('../util/print')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

// DELETE FROM localhostchurchbeam.user WHERE userToken = '_49e25bc7d3a83e090878827eb1671f01'

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

    let userToken = req.query.userToken
    let appInstallToken = req.query.appInstallToken

    print.print('userToken', userToken)
    print.print('appInstallToken', appInstallToken)
    
    if (userToken, appInstallToken) {
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
        print.print('no userToken and appInstallToken')
        res.status(400).json({
            error: "no usertoken and appInstallToken"
        })
    }
})

function getUser(token) {
    return new Promise((resolve, reject) => {
        let sql = `SELECT * FROM user WHERE userToken = '${token}'`
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

module.exports = router;