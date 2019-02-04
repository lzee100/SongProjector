const mysql = require('mysql');
const print = require('../util/print')

class Themes {

    static put (changeTheme, organizationId) {

        print.print('put theme with id', changeTheme.id)

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
        });

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
        let newTheme = theme

        if (newTheme) {
            delete newTheme.id
            newTheme.organization_id = organizationId
        }

        console.log('in post theme')
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
        });
              
        let insertPromise = new Promise ((resolve, reject) => {
            if (!newTheme) {
                print.print('no theme to post: ', newTheme)
                resolve()
            } else {
                db.query(`INSERT INTO theme SET ?`, newTheme, (err, result) => {
                    if (err) {
                        reject(err)
                    } else {
                        resolve(result.insertId)
                    }
                })
            }
        })

        return new Promise((resolve, reject) => {
            insertPromise
            .then(Themes.getTheme)
            .then(resolve)
            .catch(reject)
        })
    }

    static getTheme(themeId) {
        console.log(`get theme with ID: ${themeId}`)
        
        const mysql = require('mysql');

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
                    resolve(result[0]);
                }
            })
        })
    }
}

module.exports = Themes