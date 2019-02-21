const express = require('express')
const router = express.Router()
const print = require('../util/print')
const OrganizationClass = require('../util/organizationClass')
var db = require('../util/db')

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {
    print.print('in get roles', req.query.roleId)

    var getRoles = new Promise((resolve, reject) => {
        let sql = `SELECT * FROM role WHERE id = ${req.query.roleId}`
        db.query(sql, (err, result) => {
            if (err) {
                reject(err)
            } else {
                resolve(result)
            }
        })
       
    })

    getRoles
    .then(roles => {
        res.status(200).json(roles)
    })
    .catch(err =>{ 
        res.status(500).json(err)
    })

})

module.exports = router;