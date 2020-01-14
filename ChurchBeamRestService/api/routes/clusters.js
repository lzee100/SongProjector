const Themes = require("../util/themesClass");
const express = require('express');
const router = express.Router();
const print = require('../util/print')
const TagsClass = require('../util/tagsClass')
var Cluster = require('../util/ClusterClass')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {

    let after = req.query.updatedsince
    var where = ""
    if (after != null) {
        where = ` WHERE updatedAt >"${after}"`
    }

    let sql = `SELECT * FROM cluster` + where
    
    db.query(sql, (err, result) => {
        if(err) {
            res.status(500).json(result)
        } else {
            Promise.all(result.map(cluster => Cluster.getCluster(cluster.id))).then(function(result){
                print.print("returning clusters", result)
                res.status(200).json(result)
            }).catch(function(err){
                res.status(500).json(err)
            })
        }
    })
})

router.post('/', (req, res , next) => {
    var newClusters = req.body

    print.print('post cluster ---------------------------------------', newClusters)
    let organizationID = req.get("organizationID")
    print.print('org id', organizationID)

    // newClusters.map(cluster => 
    //     cluster.organization_id = organizationID,
    //     delete cluster.id,
    //     delete cluster.instruments
    //     )
    newClusters.map(cluster => cluster.organization_id = organizationID)
    newClusters.map(cluster => delete cluster.id)
    newClusters.map(cluster => delete cluster.instruments)

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

})

router.put('/', (req, res , next) => {
    console.log('in update cluster')
    let clusters = req.body;
    let organizationID = req.get("organizationID")
    print.print('org id', organizationID)
    print.print('put clusters', clusters)

    clusters.forEach(function(cluster, index) {
        cluster.organization_id = organizationID
    })

    Promise.all(clusters.map(cluster => Cluster.putCluster(cluster, organizationID)))
    .then(clusters => {
        print.print('in put cluster 201', clusters)
        res.status(201).json(clusters)
    })
    .catch(err => {
        print.print('in put cluster 500', err)
        res.status(500).json(err)
    })
    
})

router.delete('/', (req, res , next) => {
    console.log('in delete cluster')
    let clusters = req.body

    Promise.all(clusters.map(cluster => Cluster.deleteCluster(cluster)))
    .then(cluster => {
        print.print('deletedCluster', cluster)
        res.status(201).json(cluster)
    }).catch(err => {
        print.print('error deleting cluster', err)
        res.status(500).json(err)
    })

})

module.exports = router;

