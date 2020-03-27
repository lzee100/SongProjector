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

router.get('/', (req, res , next) => {

    let getClusterIds = function() {

        let organization_id = req.get("organizationId")
        let after = req.query.updatedsince
        var where = ` 
        WHERE organization_id = ${organization_id} 
        OR 
        (root IS NULL 
        AND organization_id IS NULL 
        AND NOT id IN 
        (SELECT root FROM cluster WHERE organization_id = ${organization_id} AND NOT root IS NULL))`
        if (after) {
            where += ` AND updatedAt >"${after}"`
        }
        let sql = `SELECT id FROM cluster` + where

        return new Promise((resolve, reject) => {
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    let clusters = result
                    let newClusters = []
                    clusters.forEach(function(cluster) {
                        let found = false
                        for(var i = 0; i < newClusters.length; i++) {
                            if (newClusters[i].id == cluster.root) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            newClusters.push(cluster)
                        }
                    })
                    resolve(newClusters)
                }
            })
        })
    }
    
    getClusterIds()
    .then(clusterIds => {
        Promise.all(clusterIds.map(clusterId => Cluster.getCluster(clusterId.id)))
        .then(function(result){
            print.print("returning clusters", result)
            res.status(200).json(result)
        }).catch(function(err){
            res.status(500).json(err)
        })
    })
    .catch(function(err){
        res.status(500).json(err)
    })

    // let sql = `SELECT * FROM cluster` + where
    
    // db.query(sql, (err, result) => {
    //     if(err) {
    //         res.status(500).json(result)
    //     } else {
    //         Promise.all(result.map(cluster => Cluster.getCluster(cluster.id))).then(function(result){
    //             print.print("returning clusters", result)
    //             res.status(200).json(result)
    //         }).catch(function(err){
    //             res.status(500).json(err)
    //         })
    //     }
    // })
})

router.post('/', (req, res , next) => {
    var newClusters = req.body
    print.print('post cluster ---------------------------------------', newClusters)
    
    let mySecret = req.headers.secret
    let organizationID = req.get("organizationId")

    if (mySecret) {
        Secret.isSecretValid(mySecret)
        .then(isValid => {
            if (!isValid) {
                res.status(401)
            } else {
                // save all clusters without organization id
                newClusters.map(cluster => cluster.isUniversal = true)
                Promise.all(newClusters.map(cluster => Cluster.postCluster(cluster)))
                .then(clusters => {
                    print.print('in result function ----------------------', clusters)
                    res.status(201).json(clusters)
                })
                .catch(err => {
                    print.print('in err function ----------------------', err)
                    res.status(500).json({ error: err })
                })
            }
        })
        .catch(err => {
            res.status(500).json({ error: err })
        })
    } else {
        // save all clusters with organization id
        newClusters.map(cluster => cluster.organization_id = organizationID)
        newClusters.map(cluster => delete cluster.id)
        newClusters.map(cluster => delete cluster.instruments)
        newClusters.map(cluster => cluster.theme.isUniversal = 0)
    
        print.print('cleaned clusters', newClusters)
        Promise.all(newClusters.map(cluster => Cluster.postCluster(cluster)))
        .then(clusters => {
            print.print('in result function ----------------------', clusters)
            res.status(201).json(clusters)
        })
        .catch(err => {
            print.print('in err function ----------------------', err)
            res.status(500).json(err)
        })
    }
})

router.put('/', (req, res , next) => {

    console.log('in update cluster')
    let clusters = req.body;
    let organizationID = req.get("organizationId")
    print.print('org id', organizationID)
    print.print('put clusters', clusters)

    let mySecret = req.headers.secret
    if (mySecret) {
        Secret.isSecretValid(mySecret)
        .then(isValid => {
            if (isValid) {
                Promise.all(clusters.map(cluster => Cluster.putCluster(cluster, organizationID, true)))
                .then(clusters => {
                    print.print('in put cluster 201', clusters)
                    res.status(201).json(clusters)
                })
                .catch(err => {
                    print.print('in put cluster 500', err)
                    res.status(500).json(err)
                })
            } else {
                res.statusCode(401).json({
                    error: "Not authrorized"
                })
            }
        })
        .catch(err => {
            res.status(500).json({
                error: err
            })
        })
    } else {
        let newClusters = clusters
        newClusters.map(cluster => cluster.isUniversal = false)
        Promise.all(newClusters.map(cluster => Cluster.putCluster(cluster, organizationID, false)))
        .then(clusters => {
            print.print('in put cluster 201', clusters)
            res.status(201).json(clusters)
        })
        .catch(err => {
            print.print('in put cluster 500', err)
            res.status(500).json(err)
        })
    }


    
})

router.delete('/', (req, res , next) => {

    console.log('in delete cluster')
    let clusters = req.body
    let organizationID = req.get("organizationId")
    print.print('org id', organizationID)
    print.print('put clusters', clusters)

    let mySecret = req.headers.secret
    if (mySecret) {
        Secret.isSecretValid(mySecret)
        .then(isValid => {
            if (isValid) {
                let asUniversal = true
                Promise.all(clusters.map(cluster => Cluster.deleteCluster(cluster, asUniversal)))
                .then(cluster => {
                    print.print('deletedCluster', cluster)
                    res.status(201).json(cluster)
                }).catch(err => {
                    print.print('error deleting cluster', err)
                    res.status(500).json(err)
                })
            } else {
                res.status(401).json({
                    error: "Not authorized"
                })
            }
        })
        .catch(err => {
            res.status(500).json({
                error: err
            })
        })
    } else { 
        let isUniversal = false 
        clusters.every(function(cluster, index) {
            isUniversal = cluster.isUniversal
            if (cluster.isUniversal) return false
            else return true
          })
        if (isUniversal) {
            res.status(401).json({
                error: 'Not authorized'
            })
        } else {
            Promise.all(clusters.map(cluster => Cluster.deleteCluster(cluster, false)))
            .then(clusters => {
                print.print('deletedCluster', clusters)
                res.status(201).json(clusters)
            }).catch(err => {
                print.print('error deleting cluster', err)
                res.status(500).json(err)
            })
        }
    }
})

module.exports = router;

