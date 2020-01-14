const mysql = require('mysql');

const db = mysql.createConnection({
    host    : 'localhost',
    user    : 'root',
    password: 'leovanderzee1986',
    database: 'localhostchurchbeam',
    timezone: 'UTC'
})

db.connect((err) => {
    if (err) {
        console.error(err);
        throw err
    }
    console.log('MySql connected...' )
})

module.exports = db; 