var db = require('./db')
var DataBaseDateClass = require('./dataBaseDateClass')
const print = require('./print')

class Tag {

    static getTagsForOrganization(organizationId) {
        return new Promise((resolve, reject) => {
            getTagsForOrganization(organizationId)
            .then(tag => {resolve(tag) })
            .catch(err => {reject(err) })
        })
    }

    static get(tagId) {
        
        return new Promise((resolve, reject) => {
            getTag(tagId)
            .then(tag => {resolve(tag) })
            .catch(err => {reject(err) })
        })
    }

    static getTagsForCluster(clusterId) {
        return new Promise((resolve, reject) => {
            getTagsForCluster(clusterId)
            .then(tags => {resolve(tags)})
            .catch(err => {reject(err)})
        })
    }

    static postTagsHasClusterIfNeeded(cluster, tags) {
        return new Promise((resolve, reject) => {
            postTagsHasClusterIfNeeded(cluster, tags)
            .then(tags => {resolve(tags)})
            .catch(err => {reject(err)})
        })
    }

    static postTag(tag) {
        return new Promise((resolve, reject) => {
            postTag(tag)
            .then(tag => {resolve(tag)})
            .catch(err => {reject(err)})
        })
    }

    static putTag(tag) {
        return new Promise((resolve, reject) => {
            putTag(tag)
            .then(tag => {resolve(tag)})
            .catch(err => {reject(err)})
        })
    }

    static deleteTag(tag) {
        return new Promise((resolve, reject) => {
            deleteTag(tag)
            .then(tag => {resolve(tag)})
            .catch(err => {reject(err)})
        })
    }

}

function getTagsForCluster(clusterId) {

    return new Promise((resolve, reject) => {
        var sql = `SELECT tag_id FROM tag_has_cluster WHERE cluster_id =${clusterId}`
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                Promise.all(result.map( tagId => getTag(tagId) ))
                .then(tags => {
                    resolve(tags)
                })
                .catch(err => {
                    reject(err)
                })
            }
        })
    })
}

    // get 1 tag, not an array
function getTag(tagId) {
    return new Promise((resolve, reject) => {
        var sql = `SELECT T.id, T.title, T.position, T.createdAt, T.updatedAt, T.deletedAt FROM tag as T WHERE T.id =${tagId}`
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                resolve(result[0])
            }
        })
    })
}

function getTagsForOrganization(organizationId) {
    return new Promise((resolve, reject) => {
        var sql = `
        SELECT T.id, T.title, T.position, T.createdAt, T.updatedAt, T.deletedAt
        FROM tag as T 
        WHERE T.organization_id = ${organizationId}`

        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                resolve(result)
            }
        })
    })
}

function postTag(tag) {
    return new Promise((resolve, reject) => {
        let sql = `INSERT INTO tag SET ?`
        db.query(sql, [tag], (err, result) => {
            if (err) {
                reject(err)
            } else {
                getTag(result.insertId)
                .then(tag => {resolve(tag) })
                .catch(err => {reject(err) })
            }
        })
    })
}

function putTag(tag) {
    return new Promise((resolve, reject) => {
        let sql = `UPDATE tag SET ? WHERE id = ${tag.id}`
        db.query(sql, [tag], (err, result) => {
            if (err) {
                reject(err)
            } else {
                getTag(tag.id)
                .then(tag => {resolve(tag) })
                .catch(err => {reject(err) })
            }
        })
    })
}

function deleteTag(tag) {
    let date = DataBaseDateClass.getDateForDataBase(new Date())

    return new Promise((resolve, reject) => {
        var sql = `UPDATE tag SET deletedAt ="${date}"`
        db.query(sql, (err, result) => {
            if(err) {
                reject(err)
            } else {
                getTag(tag.id)
                .then(tag => {resolve(tag) })
                .catch(err => {reject(err) })
            }
        })
    })
}

function submitTagsHasClusterIfNeeded(cluster, tags) {

    var deleteTagHasCluster = function(clusterId) {
        return new Promise((resolve, reject) => {
            var sql = `DELETE FROM tag_has_cluster WHERE cluster_id =${clusterId}`
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    if (result.lenght > 0) {
                        resolve(result)
                    } else {
                        resolve()
                    }
                }
            })
        })        
    }

    var insertOneTagHasCluster = function(cluster, tag) {
        return new Promise((resolve, reject) => {
            var sql = `INSERT INTO tag_has_cluster VALUES(${tag.id}, ${cluster.id}, ${cluster.theme_id}, ${cluster.organization_id})`
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                   if (result.lenght > 0) {
                    resolve(result)
                   } else {
                    resolve()
                   }
                }
            })
        })
    }

    var insertMultiTagHasCluster = function(cluster, tags) {
        return new Promise((resolve, reject) => {
            Promise.all(tags.map(tag => insertOneTagHasCluster(cluster, tag)))
            .then(resolve())
            .catch(err => { reject(err) })
        })
    }

    return new Promise((resolve, reject) => {
        deleteTagHasCluster(cluster.id)
        .then(result => {
            insertMultiTagHasCluster(cluster, tags)
            .then(resolve())
            .catch(err => {reject(err) })
        })
        .catch(err => {reject(err) })

    })

}

module.exports = Tag