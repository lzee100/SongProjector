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
    if (after) {
        where = ` WHERE updatedAt >"${after}"`
    }
    console.log(after)
    let sqlAllThemes = `SELECT * FROM theme` + where 
    console.log(sqlAllThemes)
    db.query(sqlAllThemes, (err, result) => {
        if(err) {
            res.status(500).json(err)
        } else {
            print.print('themes returned', result)
            res.status(200).json(result)
        }

    });
});

router.get('/:themeId', (req, res , next) => {
    getTheme(req.params.themeId, callback => {
        if (callback == null) {
            res.status(404).json({
                theme: callback
            });
        } else {
            res.status(200).json({
                theme: callback
            });
        }
    });
});

router.post('/', (req, res , next) => {

    let organizationID = req.get("organizationID")
    console.log(organizationID)
    var newTheme = req.body;
    if (newTheme.id) {
        delete newTheme.id
    }
    newTheme.organization_id = organizationID
    var title = req.body.title;
    console.log(`posted theme: ${title}`)
 
    let sql = 'INSERT INTO theme SET ?';
    db.query(sql, newTheme, (err, result) => {
        if (err) throw err;
        getTheme(result.insertId, callback => {
            res.status(200).json(callback[0]);
        })
    });

});

router.put('/:themeId', (req, res , next) => {
    console.log('in update theme')
    var theme = req.body;
    let organizationID = req.get("organizationID")
    console.log(organizationID)
    theme.organization_id = organizationID
    console.log("theme id")
    console.log(req.params.themeId)

    print.print('theme submitted', theme)
    
    db.query(`UPDATE theme SET ? WHERE id = ${req.params.themeId}`, [theme], (err, result) => {
        if (err) throw err;
        getTheme(req.params.themeId, callback => {
            res.status(200).json(callback[0]);
        })
    });

});

function getTheme(themeId, callback) {
    let sqlTheme = `SELECT * FROM theme WHERE id=${themeId}`
    db.query(sqlTheme, (err, result) => {
        if (err) throw err;
        console.log(result.length);
       
        // theme not found
        if (result.length == 0) {
            callback();
            return;
        }
        callback(result);
    });
};

router.delete('/:themeId', (req, res , next) => {
    console.log('in delete theme')
    let themeId = req.params.themeId

    let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
    
    console.log(`UPDATE theme SET deletedAt = "${date}" WHERE id = ${themeId}`)

    db.query(`UPDATE theme SET deletedAt = "${date}" WHERE id = ${themeId}`, (err, result) => {
        if (err) {
            res.status(500).json({
                error: result
            })
        }
        console.log('successfully deleted theme');
        getTheme(req.params.themeId, callback => {
            res.status(200).json(callback[0]);
        })
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

module.exports = router

// {
// 	"allHaveTitle" : "0",
// 	"backgroundColor" : "FFFFF",
// 	"backgroundTransparancy" : "80",
// 	"displayTime" : "0",
// 	"hasEmptySheet": "0",
// 	"imagePath" : "",
// 	"imagePathThumbnail" : "",
// 	"isEmptySheetFirst" : "0",
// 	"isHidden": "0",
// 	"isContentBold" : "0",
// 	"isContentItalic" : "0",
// 	"isContentUnderlined" : "0",
// 	"isTitleBold" : "0",
// 	"isTitleItalic" : "0",
// 	"isTitleUnderlined" : "0",
// 	"ContentAlignmentNumber" : "0",
// 	"ContentBorderColor" : "FFFFFF",
// 	"ContentBorderSize" : "0",
// 	"ContentFontName" : "Helvetica Neu",
// 	"ContentTextColor" : "FFFFFF",
// 	"position" : "0",
// 	"titleAlignmentNumber" : "0",
// 	"titleBackgroundColor" : "FFFFFF",
// 	"titleBorderColor" : "FFFFFF",
// 	"titleBorderSize" : "0",
// 	"titleFontName" : "Helvetica Neu",
// 	"titleTextColor" : "FFFFFF",
// 	"titleTextSize" : "11",
//  "title": "my first new theme"
// }