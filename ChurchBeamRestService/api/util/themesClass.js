const print = require('./print')
var db = require('./db')

class Themes {

    static put (changeTheme, organizationId) {

        print.print('put theme with id', changeTheme.id)

        console.log('in put new theme')
        let theme = changeTheme
        console.log(theme.title)
        console.log(theme.id)
        theme.organization_id = organizationId
      
        var insertTheme = new Promise ((resolve, reject) => {
            db.query(`UPDATE theme SET ? WHERE id = ${theme.id}`, [theme], (err, result) => {
                if (err) {
                    reject(err)
                }
                resolve(result.insertId)
            })
        })

        return new Promise ((resolve, reject) => {
            insertTheme
            .then(getTheme)
            .then(resolve)
            .catch(reject)
        })

    }

    static post (theme, organizationId) {
        print.print('in post theme: ', theme)

        var newTheme = theme

        if (newTheme.id) {
            delete newTheme.id
        }
        
        newTheme.organization_id = organizationId
        
        var insertPromise = new Promise ((resolve, reject) => {
            if (!newTheme) {
                print.print('no theme to post: ', newTheme)
                resolve()
            } else {
                db.query(`INSERT INTO theme SET ?`, newTheme, (err, result) => {
                    if (err) {
                        print.print('error inserting theme: ', err)
                        reject(err)
                    } else {
                        resolve(result.insertId)
                    }
                })
            }
        })

        return new Promise((resolve, reject) => {
            insertPromise
            .then(themeId => {
                print.print('inserted theme id ', themeId)
                Themes.getTheme(themeId)
                .then(resolve)
                .catch(reject)
            })
            .catch(reject)
        })
    }

    static getTheme(themeId) {
        console.log(`get theme with ID: ${themeId}`)

        return new Promise((resolve, reject) => {
            
            if (!themeId) {
                print.print('no theme id ')
                resolve()
                return
            }

            let sqlTheme = `SELECT * FROM theme WHERE id=${themeId}`
            db.query(sqlTheme, (err, result) => {
                if (err) {
                    reject(err)
                } else if (result.length == 0) {
                    resolve()
                } else {
                    print.print("success with theme")
                    resolve(result[0])
                }
            })
        })
    }

    static getThemeOn(columName, value, organizationId) {

        return new Promise((resolve, reject) => {
            let sqlTheme = `SELECT * FROM theme as T WHERE T.${columName} = ${value} AND T.organization_id = ${organizationId}`
            db.query(sqlTheme, (err, result) => {
                if (err) {
                    reject(err)
                } else if (result.length == 0) {
                    resolve()
                } else {
                    print.print("success with theme")
                    resolve(result[0])
                }
            })
        })
    }

    // static createUniversalTheme(organizationId) {

    //    let getUniversalTheme = function() {
    //         const sql =  `select T.*
    //         from theme as T
    //         inner join cluster as C on C.theme_id = T.id
    //         where C.isUniversal = 1 limit 1`

    //         return new Promise((resolve, reject) => {

    //             db.query(sql, (err, result) => {
    //                 if (err) {
    //                     reject(err)
    //                 } else {
    //                     print.print("success with theme")
    //                     resolve(result[0])
    //                 }
    //             })
    //         })
    //    }

    //    let clearTheme = function(theme) {
    //        return new Promise((resolve, reject) => {
    //             let newTheme = theme
    //             delete newTheme.id
    //             delete newTheme.createdAt
    //             delete newTheme.updatedAt
    //             delete newTheme.organization_id
    //             delete newTheme.position
    //             newTheme.organization_id = organizationId
    //             newTheme.position = 0
    //             resolve(newTheme)
    //        })
    //    }

    //    let insertClearedTheme = function(theme) {
    //         return new Promise((resolve, reject) => {
    //             let sql = `INSERT INTO theme SET ?`
    //             db.query(sql, [theme], (err, result) => {
    //                 if (err) {
    //                     reject(err)
    //                 } else {
    //                     resolve(result.insertId)
    //                 }
    //             })
    //         })
    //    }

    //    return new Promise((resolve, reject) => {
    //        getUniversalTheme()
    //        .then(clearTheme)
    //        .then(insertClearedTheme)
    //        .then(this.getTheme)
    //        .then(resolve)
    //        .catch(reject)
    //    })


    // }


}

module.exports = Themes