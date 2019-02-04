const Themes = require("./themesClass");
const express = require('express');
const router = express.Router();
const mysql = require('mysql');
const print = require('../util/print')

const db = mysql.createConnection({
    host    : 'localhost',
    user    : 'root',
    password: 'Leovanderzee1986',
    database: 'localhostchurchbeam',
    timezone: 'UTC'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('MySql connected...');
});

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

router.get('/:clusterId', (req, res , next) => {
    print.print('bla', req.params.clusterId)

    getCluster(req.params.clusterId).then(function(result){
        res.status(200).json(result);
    }).catch(function(err){
        res.status(500).json(err);
    })

    getCluster(req.params.clusterId, callback => {
        if (callback == null) {
            res.status(404).json({
                cluster: callback
            });
        } else {
            res.status(200).json({
                cluster: callback
            });
        }
    });
});

router.post('/', (req, res , next) => {

    console.log("put cluster")

    let organizationID = req.get("organizationID")
    
    var newCluster = req.body
    newCluster.organization_id = organizationID

    let sheets = newCluster.sheets
    let themeId = newCluster.tag
    let instruments = newCluster.instruments
    
    delete newCluster.sheets
    delete newCluster.tag
    delete newCluster.instruments
    if (newCluster.id) {
        delete newCluster.id
    }

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

        return new Promise((resolve, reject) => {
            var sql = 'INSERT INTO sheet SET ?'
            db.query(sql, sheet, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
            })
        })
    }
    
    var insertSheetAndTheme = function(clusterId, sheet) {
        let newSheet = sheet
        return new Promise((resolve, reject) => {
            Themes.post(sheet.tag, organizationID)
            .then(function(result){
                return new Promise((resolve, reject) => {
                    if (result) {
                        newSheet.theme_id = result.id
                    }
                    resolve()
                })
            })
            .then(function() {
                return insertSheet(clusterId, newSheet)
            })
            .then(resolve)
            .catch(reject)
        })
    }

    var insertAllSheets = function(clusterId) {
        return new Promise((resolve, reject) => {
            Promise.all(sheets.map(sheet => insertSheetAndTheme(clusterId, sheet))).then(resolve(clusterId)).catch(reject)
        })
    }


    insertCluster(themeId)
    .then(insertAllSheets)
    .then(getCluster)
    .then(function(result) {
        res.status(201).json(result)
    }).catch(function(err) {
        res.status(500).json(err)
    })

});

router.put('/:clusterId', (req, res , next) => {
    console.log('in update cluster')
    let cluster = req.body;
        
    let sheets = cluster.sheets
    let clusterTheme = cluster.tag
    let instruments = cluster.instruments

    if (sheets) {
        delete cluster.sheets
    }
    if (clusterTheme) {
        cluster.theme_id = clusterTheme
        delete cluster.tag
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
            });
        })
    }

    var saveSheetTheme = function(theme) {
        return new Promise((resolve, reject) => {
            if (!theme) {
                print.print('in resolve sheet theme | no theme')
                resolve()
            } else {
                let newtheme = theme
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

    var deleteSheetTag = function(sheet) {
        return new Promise((resolve, reject) => {
            if (sheet.theme_id) {
                db.query(`DELETE FROM tag WHERE id = ${sheet.theme_id}`, (err, result) => {
                    if (err) {
                        print.print('error deleting sheet tag', err)
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

    var deleteSheets = function(sheets) {
        return new Promise((resolve, reject) => {
            Promise.all(sheets.map(sheet => deleteSheetWithTag(sheet))).then(resolve()).catch(reject())
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
        console.log(cluster)
        print.print('cluster to return', cluster)
        res.status(201).json(cluster)
    }).catch(function(err){
        res.status(500).json(err)
    })


    

});

function getCluster(clusterId) {

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
                    newSheet.tag = result
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
                    newCluster.tag = theme.id
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
                Promise.all(sheets.map(sheet => getSheetThemes(sheet))).then(function(sheetAndThemes) {
                    newCluster.sheets = sheetAndThemes
                    resolve(newCluster)
                }).catch(reject)
            })
        }).then(function(result) {
            resolve(result)
        }).catch(reject)
    })

};

router.delete('/:clusterId', (req, res , next) => {
    console.log('in delete cluster')
    let clusterId = req.params.clusterId

    // todo: delete sheets but update cluster.deletedAt

    let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
    
    console.log(`UPDATE cluster SET deletedAt = "${date}" WHERE id = ${clusterId}`)

    db.query(`UPDATE cluster SET deletedAt = "${date}" WHERE id = ${clusterId}`, (err, result) => {
        if (err) {
            res.status(500).json({
                error: result
            })
        } else {
            getCluster(clusterId)
            .then(function(result) {
                res.status(201).json(result)
            }).catch(function(err) {
                res.status(500).json(err)
            })
        }
    });
});

function queryDb(query, ids) {
    return ids.map( id => new Promise(function(resolve, reject) {
        db.query(query, id, (err, result) => {
            if(err) {
                reject(err)
            }
            resolve(result)
        })
    }))
};

module.exports = router;