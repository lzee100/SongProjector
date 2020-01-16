const Themes = require("../util/themesClass")
const print = require('../util/print')
const TagsClass = require('../util/tagsClass')

var db = require('../util/db')


class Cluster {
    
    static postCluster(cluster) {

        let newCluster = cluster
        let organizationID = cluster.organization_id
     
        let sheets = newCluster.sheets
        let theme = newCluster.theme
        let tags = newCluster.tags
        
        delete newCluster.sheets
        delete newCluster.theme
        delete newCluster.tags
    
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
                print.print('in insert sheet 1')
                let newSheet = sheet
                if (newSheet.theme) {
                    print.print('in has theme id')
                    newSheet.theme_id = newSheet.theme.id
                    delete newSheet.theme
                }
                print.print('isnerting sheet', newSheet)
                return new Promise((resolve, reject) => {
                    var sql = 'INSERT INTO sheet SET ?'
                    db.query(sql, sheet, (err, result) => {
                        if (err) {
                            print.print('error,', err)
                            reject(err)
                        } else {
                            print.print('resolved sheet 1')
                            resolve()
                        }
                    })
                })
            }
    
            var insertSheetTheme = function(sheet, organizationID) {
                var newSheet = sheet
                print.print('insert sheet ---', sheet)
                return new Promise((resolve, reject) => {
                    if (newSheet.theme) {
                        print.print('trying sheet theme')
                        Themes.post(newSheet.theme, organizationID)
                        .then(theme => {
                            print.print('sheet theme posted', theme)
                            if (theme) {
                                delete newSheet.theme
                                newSheet.theme = theme
                                print.print('new sheet with new theme', newSheet)
                            } else if (newSheet.theme) {
                                delete newSheet.theme
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
                    .then(returnedSheet => {
                        print.print('inserted old sheet with new theme before inserting sheet', returnedSheet)
                        return insertSheet(clusterId, returnedSheet)
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
        
            insertCluster(theme.id)
            .then(insertAllSheets)
            .then(Cluster.getCluster)
            .then(cluster => {
                var newCluster = cluster
                print.print('before posting tags')
                TagsClass.postTagsHasClusterIfNeeded(newCluster, tags)
                .then(tags => {
                    print.print('success posting 1 cluster', cluster)
                    newCluster.tags = tags
                    resolve(cluster)
                })
                .catch(err => {reject(err) })
            }).catch(err => {
                print.print('error in posting 1 cluster')
                reject(err)
            })
        })
    
    }

    static putCluster(clusterToPut, organization_id) {
        var cluster = clusterToPut
        let tags = cluster.tags
        
        let sheets = cluster.sheets
        let instruments = cluster.instruments
    
        if (sheets) {
            delete cluster.sheets
        }
        if (instruments){
            delete cluster.instruments
        }
        if (tags) {
            delete cluster.tags
        }
    
    
        print.print('sheets', sheets)
    
        sheets.map(sheet => sheet.cluster_id = cluster.id)
    
        var updateCluster = function(cluster) {
            let newCluster = cluster
            if (newCluster.theme) {
                delete newCluster.theme
            }
            print.print("cluster to put", newCluster)
            return new Promise((resolve, reject) => {
                db.query(`UPDATE cluster SET ? WHERE id = ${newCluster.id}`, [newCluster], (err, result) => {
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
                    newtheme.organization_id = organization_id
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
                saveSheetTheme(sheet.theme)
                .then(function(sheetThemeId) {
                    let newSheet = sheet
                    if (sheetThemeId) {
                        newSheet.theme_id = sheetThemeId
                    }
                    if (newSheet.id) {
                        delete newSheet.id
                    }
                    if (newSheet.theme) {
                        delete newSheet.theme
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
            .then(Cluster.deleteSheets)
            .then(function() {
                return saveAllSheets(sheets)
            })
            .then(function() {
                return Cluster.getCluster(cluster.id)
            })
            .then(cluster => {
                var updatedCluster = cluster
                TagsClass.postTagsHasClusterIfNeeded(cluster, tags)
                .then(tags => {
                    updatedCluster.tags = tags
                    resolve(updatedCluster)
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

    static deleteCluster(cluster) {
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
            .then(Cluster.deleteSheets)
            .then(function() {
                Cluster.getCluster(clusterId)
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
    
    static deleteSheets(sheets) {
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

    static getCluster(clusterId) {
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
                        newSheet.theme = result[0]
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
                        newCluster.theme = theme
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
                TagsClass.getTagsForCluster(result.id)
                .then(tags => {
                    print.print('resolved tags')
                    var newCluster = result
                    newCluster.tags = tags
                    resolve(newCluster)
                })
                .catch(err => { 
                    print.print('err getting tags')
                    reject(err) 
                })
            }).catch(err => { 
                print.print('err final')
                reject(err) 
            })
        })
    
    };

    static getUniversalClusters(organization_id) {

        let getUniversalClusterIds = function() {
            return new Promise((resolve, reject) => {
                let sql = `SELECT id FROM cluster WHERE isUniversal=${1}`
                db.query(sql, (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve(result)
                    }
                })
            })
        }

        let getTheme 

        return new Promise((resolve, reject) => {
            getUniversalClusterIds()
            .then(clusterIds => {
                Promise.all(clusterIds.map(id => Cluster.getCluster(id)))
                .then(clusters => {

                    resolve(clusters)
                })
                .catch(error => {
                    reject(error)
                })
            })
            .catch(error => {
                reject(error)
            })
        })
    }
}


module.exports = Cluster
