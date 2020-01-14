const express = require('express');
const router = express.Router();
const print = require('../util/print')
var Cluster = require('../util/ClusterClass')


router.postNewSong('/', (req, res , next) => {
    console.log('in postNewSong')
    let secret = req.get("secret")

    let getOrganization = function() {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM organization WHERE id=${262}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result[0])
                }
            })
        })
    }

    let getOrganizationGuaranteed = function() {
        return new Promise((resolve, reject) => {
            getOrganization()
            .then(organization => {
                if (organization) {
                    resolve(organization)
                } else {
                    insertOrganization()
                    .then(organization => {
                        resolve(organization)
                    })
                    .catch(err => {
                        reject(err)
                    })
                }
            })
        })
    }

    let insertOrganization = function() {
        return new Promise((resolve, reject) => {
            let sql = `INSERT INTO organization (name) VALUES ('DeDeur')`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    getOrganization()
                    .then(organization => {
                        resolve(organization)
                    })
                    .catch(err => {
                        reject(err)
                    })
                }
            })
        })
    }

    if (secret == "c3GsuJwF6IwgcMy5rHIqj9wSEP4IBp8") {
        let cluster = req.body
        let theme = cluster.theme
        theme.organization_id = 262

        cluster.organization_id = 262
        cluster.isUniversal = 1

        Promise.all(getOrganizationGuaranteed(), Cluster.postCluster(cluster))
        .then(results => {
            res.status(201).json(results[1])
        })
        .catch(err => {
            res.status(500).json(err)
        })
    } else {
        res.status(401)
    }


})



module.exports = router;
