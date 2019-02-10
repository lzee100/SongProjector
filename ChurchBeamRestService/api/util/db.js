var db = module.exports = require('mysql').createConnection({
    host    : 'localhost',
    user    : 'root',
    password: 'Leovanderzee1986',
    database: 'localhostchurchbeam',
    timezone: 'UTC'
})

db.connect((err) => {
    if (err) {
        throw err
    }
    console.log('MySql connected...')
})