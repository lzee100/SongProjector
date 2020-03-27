


const Themes = require("../util/themesClass");
const express = require('express');
const router = express.Router();
const print = require('../util/print')
const TagsClass = require('../util/tagsClass')
var Cluster = require('../util/ClusterClass')
const Secret = require('../util/SecretClass')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

// does not work when you want to set a shown date for a universal cluster. If you create a user cluster, you don't have a theme for this cluster.....
router.post('/', (req, res , next) => {
    var clustersShownDate = req.body
    let organizationID = req.get("organizationId")
    let clusterIds = []

    if (!clustersShownDate) {
        res.status(200)
    } else {
        
        clustersShownDate.forEach(function(clusterShownDate) {
            clusterIds.push(clusterShownDate.id)
        })

        var getBasicCluster = function(id) {
            return new Promise((resolve, reject) => {
                let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
                db.query(`SELECT id, createdAt, updatedAt, deletedAt, lastShownAt from cluster WHERE id = ${id} AND (organization_id = ${organizationID} OR isUniversal = 1)`, (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        if (result.length == 1) {
                            resolve(result[0])
                        } else {
                            resolve()
                        }
                     }
                })
            })
        }
    
        var setShownDates = function() {
            return new Promise((resolve, reject) => {
                if (clusterIds.length == 0) {
                    resolve([])
                } else {
                    let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
                    
                    db.query(`UPDATE cluster SET lastShownAt = "${date}" WHERE id IN (?) AND organization_id = ${organizationID}`, [clusterIds], (err, result) => {
                        if (err) {
                          res.status(500).json({
                              error: err
                          })
                        } else {
                            Promise.all(clusterIds.map(id => getBasicCluster(id)))
                            .then(clusters => {
                                resolve(clusters)
                            })
                            .catch(reject)
                        }
                    })
                }
            })
        }

        setShownDates()
        .then(clusters => {
            res.status(201).json(clusters)
        })
        .catch(err => {
            res.status(500).json({
                error: err
            })
        })
    }
})




module.exports = router;

