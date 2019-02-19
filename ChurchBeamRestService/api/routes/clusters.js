const Themes = require("./themesClass");
const express = require('express');
const router = express.Router();
const print = require('../util/print')

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
            Promise.all(result.map(cluster => getCluster(cluster.id))).then(function(result){
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
    Promise.all(newClusters.map(cluster => postCluster(cluster)))
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
    let object = req.body;

    Promise.all(object.map(cluster => putCluster(cluster)))
    .then(clusters => {
        print.print('in put cluster 201', clusters)
        res.status(201).json(clusters)
    })
    .catch(err => {
        print.print('in put cluster 500', err)
        res.status(500).json(err)
    })
    
})

function postCluster(cluster) {

    let newCluster = cluster
    let organizationID = cluster.organization_id
 
    let sheets = newCluster.sheets
    let themeId = newCluster.theme_id
    
    delete newCluster.sheets
    delete newCluster.theme_id

    return new Promise((resolve, reject) => {
        sheets.forEach(function(part, index) {
            if (sheets[index].id) {
                delete sheets[index].id 
            }
            if (sheets[index].tag) {
                if (sheets[index].tag.id) {
                    delete sheets[index].tag.id
                }
            }
          }, sheets); // use arr as this
    
        print.print('sheets', sheets)
    
        var insertCluster = function(themeId) {
            newCluster.theme_id = themeId
            print.print('cluster to insert', newCluster)
            return new Promise((resolve, reject) => {
                var sql = 'INSERT INTO cluster SET ?'
                db.query(sql, newCluster, (err, result) => {
                    if (err) {
                        print.print('error insert cluster: ', err)
                        reject(err)
                    } else { 
                        print.print('cluster inserted with id: ', result.insertId)
                        resolve(result.insertId)
                    }
                })
            })
        }
    
        var insertSheet = function(clusterId, sheet) {
            let newSheet = sheet
            newSheet.cluster_id = clusterId
            if (newSheet.tag) {
                delete newSheet.tag
            }
            print.print('isnerting sheet', newSheet)
            return new Promise((resolve, reject) => {
                var sql = 'INSERT INTO sheet SET ?'
                db.query(sql, sheet, (err, result) => {
                    if (err) {
                        print.print('error,', err)
                        reject(err)
                    } else {
                        resolve()
                    }
                })
            })
        }

        var insertSheetTheme = function(sheet, organizationID) {
            var newSheet = sheet
            print.print('insert sheet ---', sheet)
            return new Promise((resolve, reject) => {
                if (newSheet.tag) {
                    print.print('trying sheet tag')
                    Themes.post(newSheet.tag, organizationID)
                    .then(theme => {
                        print.print('sheet theme posted', theme)
                        if (theme) {
                            newSheet.theme_id = theme.id
                        }
                        if (newSheet.tag) {
                            delete newSheet.tag
                        }
                        resolve(newSheet)
                    })
                    .catch(err => {
                        print.print('error asdfsadfsdf', err)
                        reject(err)
                    })
                } else {
                    print.print('instant resolving')
                    resolve(sheet)
                }
            })
        }
        
        var insertSheetAndTheme = function(clusterId, sheet) {
            print.print('in insertsheetandtheme', sheet)
            print.print('with cluster id', clusterId)
            let newSheet = sheet
            newSheet.cluster_id = clusterId
            return new Promise((resolve, reject) => {
                insertSheetTheme(newSheet, organizationID)
                .then(sheet => {
                    return insertSheet(clusterId, sheet)
                })
                .then(function(){ 
                    print.print('in resolve')
                    resolve()
                })
                .catch(function(err) {
                    print.print('error inser', err)
                    reject(err)
                })
            })
        }
    
        var insertAllSheets = function(clusterId) {
            return new Promise((resolve, reject) => {
                Promise.all(sheets.map(sheet => insertSheetAndTheme(clusterId, sheet)))
                .then(function() {
                    print.print('in resolve with cluster bla')
                    resolve(clusterId)
                })
                .catch(err => {
                    print.print('in error with cluster bla', err)
                    reject(err)
                })
            })
        }
    
    
        insertCluster(themeId)
        .then(insertAllSheets)
        .then(getCluster)
        .then(cluster => {
            print.print('success posting 1 cluster', cluster)
            resolve(cluster)
        }).catch(err => {
            print.print('error in posting 1 cluster')
            reject(err)
        })
    })

}

function putCluster(clusterToPut) {
    var cluster = clusterToPut
    cluster.organization_id = 1
    
    let sheets = cluster.sheets
    let instruments = cluster.instruments

    if (sheets) {
        delete cluster.sheets
    }
    if (instruments){
        delete cluster.instruments
    }
    print.print('sheets', sheets)

    sheets.map(sheet => sheet.cluster_id = cluster.id)

    var updateCluster = function(cluster) {
        print.print("cluster to put", cluster)
        return new Promise((resolve, reject) => {
            db.query(`UPDATE cluster SET ? WHERE id = ${cluster.id}`, [cluster], (err, result) => {
                if (err) {
                    print.print('error in update cluster', err)
                    reject()
                } else {
                    print.print('in resolve cluster xxxxxxxxxxxx')
                    resolve()
                }
            })
        })
    }

    var saveSheetTheme = function(theme) {
        return new Promise((resolve, reject) => {
            if (!theme) {
                print.print('in resolve sheet theme | no theme')
                resolve()
            } else {
                let newtheme = theme
                newtheme.organization_id = 1
                if (newtheme.id) {
                    delete newtheme.id
                }
                if (newtheme.createdAt) {
                    delete newtheme.createdAt
                    delete newtheme.updatedAt
                }
                print.print('in resolve sheet with theme')
                db.query(`INSERT theme SET ?`, [newtheme], (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve(result.insertId)
                    }
                })
            }
        })
    }

    var saveSheetWithTheme = function(sheet) {
        print.print('in resolve sheet')
        return new Promise((resolve, reject) => {
            saveSheetTheme(sheet.tag)
            .then(function(sheetThemeId) {
                let newSheet = sheet
                if (sheetThemeId) {
                    newSheet.theme_id = sheetThemeId
                }
                if (newSheet.id) {
                    delete newSheet.id
                }
                print.print('in updating sheet:')
                if (newSheet.tag) {
                    delete newSheet.tag
                }
                print.print('sheet to insert', newSheet)

                db.query(`INSERT sheet SET ?`, [newSheet], (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve()
                    }
                })
            })
        })
    }

    var saveAllSheets = function(sheets) {
        return new Promise((resolve, reject) => {
            Promise.all(sheets.map(sheet => saveSheetWithTheme(sheet))).then(resolve()).catch(reject())
        })
    }

    var getSheetsToDelete = function() {
        print.print('in delete sheets')
        return new Promise((resolve, reject) => {
            db.query(`SELECT * FROM sheet WHERE cluster_id = ${cluster.id}`, (err, result) => {
                if (err) {
                    print.print('error deleting sheet', err)
                    reject(err)
                } else {
                    print.print("sheets to delete", result)
                    resolve(result)
                }
            })
        })
    }
    
    return new Promise((resolve, reject) => {
        updateCluster(cluster)
        .then(getSheetsToDelete)
        .then(deleteSheets)
        .then(function() {
            return saveAllSheets(sheets)
        })
        .then(function() {
            return getCluster(cluster.id)
        })
        .then(cluster => {
            resolve(cluster)
        })
        .catch(err => {
            reject(err)
        })
    })
}

function getCluster(clusterId) {
    print.print('getting cluster function', clusterId)
    let getCluster = function(clusterId) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM cluster WHERE id=${clusterId}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result[0])
                }
            })
        })
    }

    let getSheets = function(cluster) {
        let newCluster = cluster
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM sheet WHERE cluster_id=${clusterId}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    print.print('success getting sheets')
                    newCluster.sheets = result
                    resolve(newCluster)
                }
            })
        })
    }

    let getSheetThemes = function(sheet) {
        return new Promise((resolve, reject) => {
            if (!sheet.theme_id) {
                resolve(sheet)
            }
            let themeId = sheet.theme_id
            let sql = `SELECT * FROM theme WHERE id=${themeId}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else if (result.length == 0) {
                    resolve(sheet)
                } else {
                    var newSheet = sheet
                    newSheet.tag = result[0]
                    resolve(newSheet)
                }
            })
        })
    }

    return new Promise((resolve, reject) => {
        getCluster(clusterId)
        .then(function(cluster) {
            let newCluster = cluster
            let themeId = newCluster.theme_id
            return new Promise((resolve, reject) => {
                Themes.getTheme(themeId).then(function(theme){
                    newCluster.theme_id = theme.id
                    resolve(newCluster)
                }).catch(reject)
            })
        })
        .then(getSheets)
        .then(function(cluster) {
            let newCluster = cluster
            let sheets = newCluster.sheets
            if (newCluster.sheets) {
                delete newCluster.sheets
            }
            return new Promise ((resolve, reject) => {
                Promise.all(sheets.map(sheet => getSheetThemes(sheet)))
                .then(function(sheetAndThemes) {
                    newCluster.sheets = sheetAndThemes
                    resolve(newCluster)
                }).catch(reject)
            })
        }).then(function(result) {
            print.print('return cluster: ', result)
            resolve(result)
        }).catch(reject)
    })

};

router.delete('/', (req, res , next) => {
    console.log('in delete cluster')
    let clusters = req.body

    Promise.all(clusters.map(cluster => deleteCluster(cluster)))
    .then(cluster => {
        print.print('deletedCluster', cluster)
        res.status(201).json(cluster)
    }).catch(err => {
        print.print('error deleting cluster', err)
        res.status(500).json(err)
    })

})

function deleteCluster(cluster) {
    let clusterId = cluster.id

    var deleteCluster = function() {
        return new Promise((resolve, reject) => {
            let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
            db.query(`UPDATE cluster SET deletedAt = "${date}" WHERE id = ${clusterId}`, (err, result) => {
                if (err) {
                  reject(err)
                } else {
                    resolve(cluster.sheets)
                }
            })
        })
    }

    return new Promise((resolve, reject) => { 
        deleteCluster()
        .then(deleteSheets)
        .then(function() {
            getCluster(clusterId)
            .then(cluster => {
                resolve(cluster)
            })
            .catch(err => {
                reject(err)
            })
        })
        .catch(err => {
            reject(err)
        })
    })
}

function deleteSheets(sheets) {
    var deleteSheetTag = function(sheet) {
        return new Promise((resolve, reject) => {
            if (sheet.theme_id) {
                db.query(`DELETE FROM theme WHERE id = ${sheet.theme_id}`, (err, result) => {
                    if (err) {
                        print.print('error deleting sheet theme', err)
                        reject(err)
                    } else {
                        resolve()
                    }
                })  
            } else {
                resolve()
            }
        })
    }

    var deleteSheet = function(sheet) {
        return new Promise((resolve, reject) => {
            db.query(`DELETE FROM sheet WHERE id = ${sheet.id}`, (err, result) => {
                if (err) {
                    print.print('error deleting sheet', err)
                    reject(err)
                } else {
                    resolve()
                }
            })  
        })
    }

    var deleteSheetWithTag = function(sheet) {
        return new Promise((resolve, reject) => {
            deleteSheetTag(sheet)
            .then(deleteSheet(sheet))
            .then(resolve())
            .catch(reject())
        })
    }

    return new Promise((resolve, reject) => {
        Promise.all(sheets.map(sheet => deleteSheetWithTag(sheet)))
        .then(resolve())
        .catch(reject())
    })
}



module.exports = router;