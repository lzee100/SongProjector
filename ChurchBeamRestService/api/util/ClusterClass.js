const Themes = require('../util/themesClass')
const print = require('../util/print')
const TagsClass = require('../util/tagsClass')
const InstrumentsClass = require('../util/instrumentsClass')
var db = require('../util/db')


class Cluster {
    
    static postCluster(cluster) {

        let newCluster = cluster
        let organizationID = cluster.organization_id
     
        let sheets = newCluster.sheets
        let theme = newCluster.theme
        let tags = newCluster.tags
        let instruments = newCluster.instruments
        
        delete newCluster.sheets
        delete newCluster.theme
        delete newCluster.tags
        delete newCluster.instruments
    
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
                if (sheets[index].theme) {
                    if (sheets[index].theme.id) {
                        delete sheets[index].theme.id
                    }
                }
              }, sheets);
              if (instruments) {
                instruments.forEach(function(part, index) {
                    if (instruments[index].id) {
                        delete instruments[index].id 
                    }
                  }, instruments);
              }
            
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
                TagsClass.postTagsHasCluster(newCluster, tags)
                .then(tags => {
                    print.print('success posting 1 cluster', cluster)
                    newCluster.tags = tags
                    if (instruments) {
                        Promise.all(instruments.map(instrument => InstrumentsClass.postInstrument(instrument, newCluster.id)))
                        .then(instruments => {
                            return Cluster.getCluster(newCluster.id)
                        })
                        .then(cluster => {
                            resolve(cluster)
                        })
                        .catch(err => {reject(err) })
                    } else {
                        Cluster.getCluster(newCluster.id)
                        .then(resolve)
                        .catch(reject)
                    }
                })
                .catch(err => {reject(err) })
            }).catch(err => {
                print.print('error in posting 1 cluster')
                reject(err)
            })
        })
    
    }

    static putCluster(clusterToPut, organization_id, asUniversal) {

        var updateCluster = function(cluster) {
            return new Promise((resolve, reject) => {
                db.query(`UPDATE cluster SET ? WHERE id = ${cluster.id}`, [cluster], (err, result) => {
                    if (err) {
                        reject()
                    } else {
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
                Promise.all(sheets.map(sheet => saveSheetWithTheme(sheet)))
                .then(resolve)
                .catch(reject)
            })
        }
    
        var getSheetsToDelete = function() {
            print.print('in delete sheets')
            return new Promise((resolve, reject) => {
                db.query(`SELECT * FROM sheet WHERE cluster_id = ${clusterToPut.id}`, (err, result) => {
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
            if (!clusterToPut.root && !asUniversal) {
                clusterToPut.organization_id = organization_id
                createNewClusterFrom(clusterToPut, organization_id)
                .then(resolve)
                .catch(reject)
            } else {
                var cluster = clusterToPut
                let tags = cluster.tags
                if (cluster.theme) {
                    cluster.theme_id = cluster.theme.id
                    delete cluster.theme
                }
                
                let sheets = cluster.sheets
                let instruments = []
                if (cluster.instruments) {
                    instruments = cluster.instruments
                }
            
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

                updateCluster(cluster)
                .then(getSheetsToDelete)
                .then(Cluster.deleteSheets)
                .then(result => {
                    saveAllSheets(sheets)
                    .then(TagsClass.postTagsHasCluster(cluster, tags))
                    .then(Promise.all(instruments.map(instrument => InstrumentsClass.postInstrumentHasClusterIfNeeded(instrument.id, cluster.id))))
                    .then(result => {
                        Cluster.getCluster(cluster.id)
                        .then(cluster => {
                            resolve(cluster)
                        })
                        .catch(reject)
                    })
                })
                .catch(reject)
            }
        })
    }

    static deleteCluster(cluster, asUniversal) {
        let clusterId = cluster.id
    
        var deleteCluster = function(asUniversal) {
            return new Promise((resolve, reject) => {
                let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
                let asUniversalQuery = ""
                if (asUniversal) {
                   asUniversalQuery = ` OR root = ${clusterId}`
                }
                db.query(`UPDATE cluster SET deletedAt = "${date}" WHERE id = ${clusterId}` + asUniversalQuery, (err, result) => {
                    if (err) {
                      reject(err)
                    } else {
                        resolve()
                    }
                })
            })
        }
    
        return new Promise((resolve, reject) => { 
            deleteCluster(asUniversal)
            .then(function() {
                Cluster.getCluster(clusterId)
                .then(cluster => {
                    resolve(cluster)
                })
                .catch(err => {
                    reject(err)
                })
            })
            .catch(reject)
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
                .then(resolve)
                .catch(reject)
            })
        }
    
        return new Promise((resolve, reject) => {
            Promise.all(sheets.map(sheet => deleteSheetWithTag(sheet)))
            .then(result => {
                resolve()
            })
            .catch(reject)
        })
    }

    static getCluster(clusterId) {

        // returns cluster and Theme
        let getCluster = function(clusterId) {
            let getCluster = function() {
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

            let getClusterTheme = function(cluster) {
                let themeId = cluster.theme_id
                return new Promise((resolve, reject) => {
                    Themes.getTheme(themeId)
                    .then(theme => {
                        let newCluster = cluster
                        newCluster.theme = theme
                        resolve(newCluster)
                    })
                    .catch(reject)
                })
            }

            return new Promise((resolve, reject) => {
                getCluster()
                .then(getClusterTheme)
                .then(resolve)
                .catch(reject)
            })
        }
    
        // return cluster and sheet with themes
        let getSheets = function(cluster) {
            
            let getSheets = function() {
                return new Promise((resolve, reject) => {
                    let sql = `SELECT * FROM sheet WHERE cluster_id=${clusterId}`
                    db.query(sql, (err, result) => {
                        if (err) {
                            reject(err)
                        } else {
                            let newCluster = cluster
                            newCluster.sheets = result
                            resolve(newCluster)
                        }
                    })
                })
            }

            let getSheetThemes = function(clusterWithCleanSheets) {
                let sheets = clusterWithCleanSheets.sheets
                return new Promise((resolve, reject) => {
                    Promise.all(sheets.map(sheet => getSheetTheme(sheet)))
                    .then(sheetWithThemes => {
                        let newCluster = cluster
                        newCluster.sheets = sheetWithThemes
                        resolve(newCluster)
                    })
                    .catch(reject)
                })
            }

            let getSheetTheme = function(sheet) {
                return new Promise((resolve, reject) => {
                    if (sheet.theme_id) {
                        Themes.getTheme(sheet.theme_id)
                        .then(theme => {
                            let newSheet = sheet
                            newSheet.theme = theme
                            resolve(newSheet)
                        })
                        .catch(reject)
                    } else {
                        resolve(sheet)
                    }
                })
            }

            return new Promise((resolve, reject) => {
                getSheets()
                .then(getSheets)
                .then(getSheetThemes)
                .then(resolve)
                .catch(reject)
            })
        }

        let getTags = function(cluster) {
                return new Promise((resolve, reject) => {
                    TagsClass.getTagsForCluster(cluster.id)
                    .then(tags => {
                        let newCluster = cluster
                        newCluster.tags = tags
                        resolve(newCluster)
                    })
                    .catch(reject)
                })
        }

        let getInstruments = function(cluster) {
            return new Promise((resolve, reject) => {
                InstrumentsClass.getInstruments(cluster.id)
                .then(instruments => {
                    let newCluster = cluster
                    newCluster.instruments = instruments
                    resolve(newCluster)
                })
                .catch(reject)
            })
        }
        
        return new Promise((resolve, reject) => {
            getCluster(clusterId)
            .then(getSheets)
            .then(getTags)
            .then(getInstruments)
            .then(cluster => {
                resolve(cluster)
            })
            .catch(err => { 
                print.print('err ClusterClass getCluster')
                reject(err) 
            })
        })
    
    }
}

function createNewClusterFrom(editedUniversalCluster, organizationId) {
    
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
                .then(themeId => {
                    if (thisSheet.theme) {
                        delete thisSheet.theme
                    }
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

    let insertTags = function(clusterThemeSheets) {
        let newTags = []
        clusterThemeSheets.tags.forEach(function(tag) {
            let newTag = tag
            delete newTag.createdAt
            delete newTag.updatedAt
            delete newTag.organization_id
            newTag.organization_id = organizationId
            newTags.push(newTag)
        })

        let clusterTemp = {
            id: clusterThemeSheets.clusterId
        }

        return new Promise((resolve, reject) => {
            TagsClass.postTagsHasCluster(clusterTemp, newTags)
            .then(result => {
                resolve(clusterThemeSheets.clusterId)
            })
            .catch(reject)
        })
        
    }

    let insertClusterHasInstruments = function(clusterThemeSheets) {
        let clusterId = clusterThemeSheets.clusterId
        let instruments = clusterThemeSheets.instruments
        
        return new Promise((resolve, reject) => {
            if (instruments) {
                Promise.all(instruments.map(instrument => InstrumentsClass.postInstrumentHasClusterIfNeeded(instrument.id, clusterId)))
                .then(result => {
                    resolve(clusterThemeSheets)
                })
                .catch(reject)
            } else {
                resolve(clusterThemeSheets)
            }
        })
    }

    let editUniversalCluster = editedUniversalCluster
    editUniversalCluster.theme_id = editedUniversalCluster.theme.id
    editUniversalCluster.root = editedUniversalCluster.id
    
    editUniversalCluster.organization_id = organizationId
    // editUniversalCluster.isUniversal = 0
    
    let sheets = editUniversalCluster.sheets
    let instruments = editUniversalCluster.instruments
    let tags = editUniversalCluster.tags
    let universalClusterId = editUniversalCluster.id

    delete editUniversalCluster.id
    delete editUniversalCluster.createdAt
    delete editUniversalCluster.updatedAt
    delete editUniversalCluster.sheets
    delete editUniversalCluster.theme
    delete editUniversalCluster.instruments
    delete editUniversalCluster.tags

    sheets.forEach(function(part, index, sheets) {
        delete sheets[index].id,
        delete sheets[index].createdAt,
        delete sheets[index].updatedAt,
        delete sheets[index].theme_id
    })

    let clusterThemeSheets = {
        'universalClusterId': universalClusterId,
        'organizationId': organizationId,
        'cluster': editUniversalCluster,
        'sheets': sheets,
        'instruments': instruments,
        "tags": tags
    }

    return new Promise((resolve, reject) => {
        
        insertCluster(clusterThemeSheets)
        .then(insertSheets)
        .then(insertClusterHasInstruments)
        .then(insertTags)

        .then(Cluster.getCluster)
        .then(result => {
            resolve(result)
        })
        .catch(reject)
    })
    
}


module.exports = Cluster
