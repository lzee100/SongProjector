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
                return resolve()
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
}

module.exports = Themes