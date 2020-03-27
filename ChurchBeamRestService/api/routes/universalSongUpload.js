const express = require('express');
const router = express.Router();
const print = require('../util/print')
var Cluster = require('../util/ClusterClass')
var db = require('../util/db')
const Secret = require('../util/SecretClass')

router.post('/', (req, res , next) => {
    console.log('in postNewSong')
    let mySecret = req.get('secret')
    let organizationId = req.get('organizationId')
    var unprocessedClusters = req.body
    var newClusters = []

    unprocessedClusters.forEach(cluster => {
        let newCluster = cluster
        delete newCluster.id
        newCluster.organization_id = organizationId
        newCluster.isUniversal = 1
        newClusters.push(newCluster)
    });

    Secret.getSecret()
    .then(secret => {
        if (mySecret != secret.secret) {
            res.status(401)
        } else {
            Promise.all(newClusters.map(cluster => Cluster.postCluster(cluster)))
            .then(clusters => {
                res.status(201).json(clusters)
            })
            .catch(err => {
                res.status(500).json(err)
            })
        }
    })
    .catch(err => {
        res.status(500).json(err)
    })


})



module.exports = router;
