const print = require('./print')
var db = require('./db')
var DataBaseDateClass = require('./dataBaseDateClass')


class SongServiceSettings {

    static put (songServiceSettings, organizationId) {
        return putSongServiceSettings(songServiceSettings, organizationId)
    }

    static post (songServiceSettings, organizationId) {
        return postSongServiceSettings(songServiceSettings, organizationId)
    }

    static get(id) {
        let nil
        return getSongServiceSettings(id, nil)
    }

    static getForOrganization(organizationId) {
        let nil
        return getSongServiceSettings(nil, organizationId)
    }

    static delete(id) {
        return deleteSongServiceSettings(id)
    }
}

function postSongServiceSettings(songServiceSettings, organizationId) { 

    let newSongServiceSettings = songServiceSettings
    delete newSongServiceSettings.id

    var insertSection = function(section) {
        let newsection = section
        if (newsection.tags) {
            delete newsection.tags
            delete newsection.id
        }
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO songServiceSection SET ?`
            db.query(sql, [newsection], (err, result) => {
               if (err) {
                   reject(err)
               } else {
                   resolve(result.insertId)
               }
            })
        })
    }

    var insertSectionHasTag = function(section, tag) {
         return new Promise((resolve, reject) => {
            let tagHasSection = { 
                songServiceSection_id: section.id, 
                songServiceSection_songServiceSettings_id: section.songServiceSettings_id,
                songServiceSection_songServiceSettings_organization_id: organizationId,
                tag_id: tag.id,
                tag_organization_id: organizationId
             }
             const sql = `INSERT INTO tag_has_songServiceSection SET ?`
             db.query(sql, [tagHasSection], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
             })
         })
    }

    var handleSection = function(section) {
        let newSection = section
        let tags = section.tags
        return new Promise((resolve, reject) => {
            if (!tags) {
                resolve()
            } else {
                insertSection(section)
                .then(sectionId => {
                    newSection.id = sectionId
                    Promise.all(tags.map(tag => insertSectionHasTag(newSection, tag)))
                    .then(function() {
                        resolve()
                    })
                    .catch(err => { reject(err) })
                })
                .catch(err => { 
                    reject(err)
                 })
            }
        })
    }

    var insertSections = function(songServiceSettings) {
        let newSections = songServiceSettings.sections
        newSections.map(section => section.songServiceSettings_id = songServiceSettings.id)
        newSections.map(section => section.songServiceSettings_organization_id = organizationId)

        return new Promise((resolve, reject) => {
            Promise.all(newSections.map(section => handleSection(section)))
            .then(resolve())
            .catch(err => { 
                reject(err) 
            })
        })
    }

    var insertSongServiceSetting = function (songServiceSettings) {
        return new Promise((resolve, reject) => {
            let newSetting = songServiceSettings
            let sections = newSetting.sections
            if (newSetting.sections) {
                delete newSetting.sections
            }
            const sql = `INSERT INTO songServiceSettings SET ?`
            db.query(sql, [newSetting], (err, result) => {
               if (err) {
                   reject(err)
               } else {
                    newSetting.id = result.insertId
                    newSetting.sections = sections
                    resolve(newSetting)
               }
            })
        })
    }

    return new Promise((resolve, reject) => {
        insertSongServiceSetting(newSongServiceSettings)
        .then(setting => {
            insertSections(setting)
            .then(function() {
                getSongServiceSettings(setting.id)
                .then(settings => {
                    resolve(settings)
                })
                .catch(err => { reject(err) })
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

function putSongServiceSettings(songServiceSettings, organizationId) { 

    var updateSettings = function(settings) {
        let newSettings = settings
        if (newSettings.sections) {
            delete newSettings.sections
        }

        return new Promise((resolve, reject) => {
            let sql = `UPDATE songServiceSettings SET ? WHERE id = ${settings.id}`
            db.query(sql, [newSetting], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
            })
        })
    }

    var deleteSectionHasTag = function(section) {
        let sectionId = section.id
        return new Promise((resolve, reject) => {
            let sql = `DELETE tag_has_songServiceSection WHERE songServiceSection_id = ${sectionId}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
            })
        })
    }

    var insertSectionHasTag = function(section, tag) {
        let tagHasSection = { 
            songServiceSection_id: section.id, 
            songServiceSection_songServiceSettings_id: section.songServiceSettingsId,
            songServiceSection_songServiceSettings_organization_id: organizationId,
            tag_id: tag.id,
            tag_organization_id: organizationId
         }

         return new Promise((resolve, reject) => {
             const sql = `INSERT INTO tag_has_songServiceSection SET ?`
             db.query(sql, [tagHasSection], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
             })
         })
    }

    var insertSectionHasTags = function(section) {
        return new Promise((resolve, reject) => {
            Promise.all(section.tags.map(tag => insertSectionHasTag(section, tag)))
            .then(resolve())
            .catch(err => { reject(err) })
        })
    }

    var updateSection = function(section) {
        let newSection = section
        if (newSection.tags) {
            delete newSection.tags
        }
        var updateSection = new Promise((resolve, reject) => {
            let sql = `UPDATE songServiceSection SET ? WHERE id = ${newSection.id}`
            db.query(sql, [newSection], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve()
                }
            })
        }) 

        deleteSectionHasTag(section)
        .then(function() {
            updateSection
            .then(function() {
                insertSectionHasTags(section)
                .then(resolve())
                .catch(err => { reject(err) })
            })
            .catch(err => { reject(err) })
        })
        .catch(err => { reject(err) })

    }

    var updateSections = function (sections) {
        return new Promise((resolve, reject) => {
            Promise.all(sections.map(section => updateSection(section)))
            .then(resolve())
            .catch(err => { reject(err) })
        })
    }

    return new Promise((resolve, reject) => {
        updateSettings(songServiceSettings)
        .then(function() {
            updateSections(songServiceSettings.sections)
            .then(function() {
                getSongServiceSettings(songServiceSettings.id)
                .then(settings => {
                    resolve(settings)
                })
                .catch(err => { reject(err) })
            })
            .catch(err => { reject(err) })
        })
    })

}

function deleteSongServiceSettings(id) {
    let deleteDate = DataBaseDateClass.getDateForDataBase(new Date())

    return new Promise((resolve, reject) => {
        let sql = `UPDATE songServiceSettings SET deletedAt = "${deleteDate}" WHERE id = ${id}`
        db.query(sql, (err, result) => {
            if (err) {
                reject(err)
            } else {
                getSongServiceSettings(id)
                .then(settings => {
                    resolve(settings)
                })
                .catch(err => { reject(err) })
            }
        })
    })
}

function getSongServiceSettings(id, organizationId) {

    var getSettings = function(id, organizationId) {
        let where = ""
        if (id) {
            where = `id = ${id}`
        } else {
            where = `organization_id = ${organizationId}`
        }
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM songServiceSettings WHERE ` + where
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    if (result.length > 0) {
                        resolve(result[result.length - 1])
                    } else {
                        resolve()
                    }
                }
            })
        })
    }

    var getSections = function(id) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM songServiceSection WHERE songServiceSettings_id = ${id}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(result)
                }
            })
        })
    }

    var getTagForSection = function(section) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT T.id, T.title, T.createdAt, T.updatedAt, T.deletedAt FROM tag as T LEFT JOIN tag_has_songServiceSection as ST ON T.id = ST.tag_id WHERE ST.songServiceSection_id = ${section.id}`
            db.query(sql, (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    let newSection = section
                    newSection.tags = result
                    resolve(newSection)
                }
            })
        })
    }

    return new Promise((resolve, reject) => {
        getSettings(id, organizationId)
        .then(settings => {
            if (settings) {
                getSections(settings.id)
                .then(sections => {
                    Promise.all(sections.map(section => getTagForSection(section)))
                    .then(sectionWithTags => {
                        let newSettings = settings
                        newSettings.sections = sectionWithTags
                        print.print("settings", newSettings)
                        resolve([newSettings])
                    })
                    .catch(err => { reject(err) })
                })
                .catch(err => { reject(err) })
            }
            else {
                resolve([])
            }
        })
        .catch(err => { reject(err) })
    })
}


module.exports = SongServiceSettings