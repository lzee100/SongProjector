const express = require('express');
const router = express.Router();
const print = require('../util/print')
var db = require('../util/db')
const Secret = require('../util/SecretClass')


router.get("/", (req, res, next) => {
    let mySecret = req.query.secret
    print.print('secret', mySecret)
    Secret.getSecret() 
    .then(secret => {
        if (mySecret == secret.secret) {
            print.print('suceess secret')
            res.status(201).json([])
        } else {
            print.print('failure secret')
            res.status(401).json({
                error: "No access to requested information"
            })
        }
    })
})


 
module.exports = router;