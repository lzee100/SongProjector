const express = require('express');
const router = express.Router();
const print = require('../util/print')
var ClusterClass = require('../util/ClusterClass')
var db = require('../util/db')
const Secret = require('../util/SecretClass')
const TagClass = require('../util/tagClass')
const ThemeClass = require('../util/themesClass')

// truncate table user;
// truncate table organization;
// truncate table role;
// truncate table user_has_role;
// truncate table contractLedger;
// truncate table contract_has_organization;
// truncate table theme;

// truncate table cluster;
// truncate table sheet;
// truncate table instrument;
// truncate table organization_has_universalCluster;




router.get('/', (req, res , next) => {
    console.log('in get new content')

    let organizationId = req.get("organizationId")
    getUniversalCluster(organizationId)
    .then(cluster => {
        console.log('resolve new content')
        res.status(200).json(cluster)
    })
    .catch(err => {
        console.log('err new content')
        res.status(500).json(err)
    })

})






function createNewClusterFrom(editedUniversalCluster, organizationId) {
    
    // let getAlreadyFetchedClustersIds = function() {
    //     return new Promise((resolve, reject) => {
    //         let sql = `select universalCluster_id from organization_has_universalCluster where organization_id = ${organizationId}`
    //         db.query(sql, (err, result) => {
    //             if(err) {
    //                 reject(err)
    //             } else {
    //                 resolve(result)
    //             }
    //         })
    //     })
    // }

    // let getUniversalClusterId = function(alreadyFetchedClusterIds) {
    //     let idValues = []
    //     alreadyFetchedClusterIds.forEach(function(item) {
    //         idValues.push(item.cluster_id)
    //     })
    //     return new Promise((resolve, reject) => {
    //         let sql = ""
    //         if (idValues.length > 0) {
    //             sql = "select id from cluster WHERE NOT id IN (?) AND isUniversal = 1 AND deletedAt IS NULL LIMIT 1"
    //         } else {
    //             sql = "select id from cluster WHERE isUniversal = 1 AND deletedAt IS NULL LIMIT 1"
    //         }
    //         db.query(sql, idValues, (err, result) => {
    //             if(err) {
    //                 reject(err)
    //             } else {
    //                 if (result.length == 0) {
    //                     resolve()
    //                 } else {
    //                     resolve(result[0].id)
    //                 }
    //             }
    //         })
    //    })
    // }

    let getInsertedCluster = function(cluster) {
        let clusterId = cluster.clusterId
        return new Promise((resolve, reject) => {
            ClusterClass.getCluster(clusterId)
            .then(resultCluster => {
                resolve([resultCluster])
            })
            .catch(reject)
        })
    }

    let insertInstrument = function(instrument, clusterId) {
        let newInstrument = instrument
        delete newInstrument.id
        delete newInstrument.cluster_id
        delete newInstrument.createdAt
        delete newInstrument.updatedAt
        newInstrument.cluster_id = clusterId
        return new Promise((resolve, reject) => {
            db.query(`INSERT instrument SET ?`, [instrument], (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    resolve(result.insertId)
                }
            })
       })
    }

    // let insertInstruments = function(cluster) {
    //     let instruments = cluster.instruments
    //     return new Promise((resolve, reject) => {
    //         Promise.all(instruments.map(instrument => insertInstrument(instrument, cluster.clusterId)))
    //         .then(instrumentIds => {
    //             resolve(cluster)
    //         })
    //         .catch(reject)
    //     })
    // }

    let insertSheetTheme = function(theme) {
        let newTheme = theme
        delete newTheme.id
        delete newTheme.createdAt
        delete newTheme.updatedAt
        delete newTheme.organization_id
        newTheme.organization_id = organizationId

        return new Promise((resolve, reject) => {
            db.query(`INSERT theme SET ?`, [newTheme], (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    resolve(result.insertId)
                }
            })
       })
    }

    let insertSheet = function(sheet, clusterId) {
        let thisSheet = sheet
        thisSheet.cluster_id = clusterId

        return new Promise((resolve, reject) => {

            if (sheet.theme) {
                insertSheetTheme(sheet.theme)
                .theme(themeId => {
                    thisSheet.theme_id = themeId
                    db.query(`INSERT sheet SET ?`, [thisSheet], (err, result) => {
                        if(err) {
                            reject(err)
                        } else {
                            resolve(result.insertId)
                        }
                    })
                })
                .catch(err => {
                    reject(err)
                })
            } else {
                db.query(`INSERT sheet SET ?`, [thisSheet], (err, result) => {
                    if(err) {
                        reject(err)
                    } else {
                        resolve(result.insertId)
                    }
                })
            }
       })
    }

    let insertSheets = function(cluster) {
        let sheets = cluster.sheets
        return new Promise((resolve, reject) => {
            Promise.all(sheets.map(sheet => insertSheet(sheet, cluster.clusterId)))
            .then(sheetsIds => {
                resolve(cluster)
            })
            .catch(reject)
        })
    }

    let insertCluster = function(cluster) {
        let inserted = cluster.cluster
        return new Promise((resolve, reject) => {
            db.query(`INSERT cluster SET ?`, [inserted], (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    let newCluster = cluster
                    newCluster.clusterId = result.insertId
                    resolve(newCluster)
                }
            })
       })
    }

    let insertNewThemeIfNeeded = function(clusterThemeSheets) {
        let theme = clusterThemeSheets.theme

        let insertNewTheme = function() {
            return new Promise((resolve, reject) => {
                let newTheme = clusterThemeSheets.cluster.theme
                delete newTheme.id
                delete newTheme.createdAt
                delete newTheme.updatedAt
                delete newTheme.organization_id
                newTheme.organization_id = organizationId
                ThemeClass.post(newTheme, organizationId)
                .then(resolve)
                .catch(reject)
            })
        }

        return new Promise((resolve, reject) => {
            // check if existing theme for this organization
        if (theme.organization_id == organizationId) {
            let newClusterThemeSheets = clusterThemeSheets
            newClusterThemeSheets.themeId = theme.id
            resolve(newClusterThemeSheets)
        } else {
            insertNewTheme()
            .then(theme => {
                let newClusterThemeSheets = clusterThemeSheets
                newClusterThemeSheets.themeId = theme.id
                resolve(newClusterThemeSheets)
            })
        }
        })
    }

    let insertTags = function(clusterThemeSheets) {
        let newTags = []
        clusterThemeSheets.tags.forEach(function(tag) {
            let newTag = tag
            delete newTag.id
            delete newTag.createdAt
            delete newTag.updatedAt
            delete newTag.organization_id
            newTag.organization_id = organizationId
        })

        let clusterTemp = {
            id: clusterThemeSheets.clusterId,
            theme_id: clusterThemeSheets.themeId,
            organization_id: organizationId
        }

        return new Promise((resolve, reject) => {
            TagClass.postTagsHasCluster(clusterTemp, newTags)
            .then(result => {
                resolve(clusterThemeSheets)
            })
            .catch(reject)
        })
        
    }

    // let checkAndSetClusterTheme = function(cluster) {

    //     let getMostUsedTheme = function() {
    //         let sql = `
    //         SELECT COUNT(title) as countedTitle, title
    //         FROM theme
    //         WHERE organization_id = ${organizationId}
    //         GROUP BY title 
    //         order by countedTitle 
    //         desc limit 1`

    //         return new Promise((resolve, reject) => {
    //             db.query(sql, (err, result) => {
    //                 if(err) {
    //                     reject(err)
    //                 } else {
    //                     let title = result.title
    //                     resolve(title)
    //                 }
    //             })
    //          })
    //     }

    //     let getOrCreateTheme = function(title) {
    //         return new Promise((resolve, reject) => {
    //             if (title) {
    //                 ThemeClass.getThemeOn('title', title, organizationId)
    //                 .then(theme => {
    //                     let newCluster = cluster
    //                     newCluster.cluster.theme_id = theme.id
    //                     resolve(newCluster)
    //                 })
    //                 .catch(reject)
    //             } else {
    //                 ThemeClass.createUniversalTheme(organizationId)
    //                 .then(newTheme => {
    //                     let newCluster = cluster
    //                     newCluster.cluster.theme_id = newTheme.id
    //                     newCluster.themeId = newTheme.id
    //                     resolve(newCluster)
    //                 })
    //                 .catch(reject)
    //             }
    //         })
    //     }

    //     return new Promise((resolve, reject) => {
    //         getMostUsedTheme()
    //         .then(getOrCreateTheme)
    //         .then(resolve)
    //         .catch(reject)
    //     })
    // }

    // let insertOrganizationHasUniversalCluster = function(cluster) {
    //     let properties = {
    //         universalCluster_id: cluster.universalClusterId,
    //         organization_id: cluster.organizationId,
    //         cluster_id: cluster.clusterId
    //     }
    //     return new Promise((resolve, reject) => {
    //         db.query(`INSERT INTO organization_has_universalCluster SET ?`, [properties], (err, result) => {
    //             if(err) {
    //                 reject(err)
    //             } else {
    //                 resolve(cluster)
    //             }
    //         })
    //    })
    // }

    // let universalClusterToMyCluster = function(themeId) {

        let editUniversalCluster = editedUniversalCluster
        
        editUniversalCluster.organization_id = organizationId
        // editUniversalCluster.isUniversal = 0
        
        let sheets = editUniversalCluster.sheets
        let instruments = editUniversalCluster.instruments
        let tags = universalCluster.tags
        let universalClusterId = universalCluster.id
        let theme = editUniversalCluster.theme

        delete editUniversalCluster.id
        delete editUniversalCluster.createdAt
        delete editUniversalCluster.updatedAt
        delete editUniversalCluster.sheets
        delete editUniversalCluster.theme
        delete editUniversalCluster.theme_id
        delete editUniversalCluster.instruments
        delete editUniversalCluster.tags

        sheets.forEach(function(part, index, sheets) {
            delete sheets[index].id,
            delete sheets[index].createdAt,
            delete sheets[index].updatedAt,
            delete sheets[index].theme_id
          })

          instruments.forEach(function(part, index, instruments) {
            delete instruments[index].id,
            delete instruments[index].createdAt,
            delete instruments[index].updatedAt,
            delete instruments[index].cluster_id
          })

          let clusterThemeSheets = {
            'universalClusterId': universalClusterId,
            'organizationId': organizationId,
            'cluster': editUniversalCluster,
            'theme': theme,
            'sheets': sheets,
            'instruments': instruments,
            "tags": tags
          }

         return new Promise((resolve, reject) => {
            
            insertNewThemeIfNeeded(clusterThemeSheets)
            // checkAndSetClusterTheme(clusterThemeSheets)
            .then(insertCluster) //
            .then(insertSheets)
            .then(insertTags)
            // .then(insertInstruments)
            // .then(insertOrganizationHasUniversalCluster)
            .then(getInsertedCluster)
            .then(resolve)
            .catch(reject)
         })
    // }

    // return new Promise((resolve, reject) => {
    //     insertNewTheme(cluster.theme)
    //     .then(universalClusterToMyCluster)
    //     .then(resolve)
    //     .catch(reject)

    //     // getAlreadyFetchedClustersIds()
    //     // .then(getUniversalClusterId)
    //     // .then(clusterId => {
    //     //     if (!clusterId) {
    //     //         resolve([])
    //     //     } else {
    //     //         ClusterClass.getCluster(clusterId)
    //     //         .then(universalClusterToMyCluster)
    //     //         .then(resolve)
    //     //         .catch(err => {
    //     //             reject(err)
    //     //         })
    //     //     }
    //     // })
    //     // .catch(err => {
    //     //     reject(err)
    //     // })
    // })
}   

// function insertNewSongTagIfNeeded(cluster) {
//     let clusterTemp = {
//         id: cluster.clusterId,
//         theme_id: cluster.themeId,
//         organization_id: cluster.organizationId
//     }
//     return new Promise((resolve, reject) => {
//         let newCluster = cluster
//         let filter = []
//         filter.push({ columname: 'title', value: 'Nieuw'})
//         let hasDeleted = false
//         TagClass.getFirstTagWhere(filter, cluster.organizationId, hasDeleted)
//         .then(tag => {
//             if (tag) {
//                 TagClass.postTagsHasCluster(clusterTemp, [tag])
//                 .then(result => {
//                     newCluster.tags = [tag]
//                     resolve(newCluster)
//                 })
//                 .catch(reject)
//             } else {
//                 TagClass.getNewTagPosition(cluster.organizationId)
//                 .then(tagPosition => {
//                     let tag = {
//                         title: 'Nieuw',
//                         position: tagPosition,
//                         organization_id: cluster.organizationId
//                     }
//                     TagClass.postTag(tag)
//                     .then(tag => {
//                         newCluster.tags = [tag]
//                         TagClass.postTagsHasCluster(clusterTemp, [tag])
//                         .then(result => {
//                             resolve(newCluster)
//                         })
//                         .catch(reject)
//                     })
//                     .catch(reject)
//                 })
//             }
//         })
//         .catch(reject)
//     })

// }

module.exports = router;
