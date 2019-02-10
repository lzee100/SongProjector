const express = require('express');
const router = express.Router();
const print = require('../util/print')
var db = require('../util/db');


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

    print.print('themes posted: ', req.body)

    let organizationID = req.get("organizationID")
    var newThemes = req.body;

    newThemes.map(theme => theme.organization_id = organizationID)
    newThemes.map(theme => delete theme.id)

    Promise.all(newThemes.map(theme => postTheme(theme)))
    .then(themes => {
        print.print('in resolve themes', themes)
        res.status(200).json(themes);
    })
    .catch(err => {
        print.print(' in error themes', err)
        res.status(500).json(err);
    })
})

function postTheme(theme) {
    var newTheme = theme
    return new Promise((resolve, reject) => {    
        let sql = 'INSERT INTO theme SET ?';
        db.query(sql, newTheme, (err, result) => {
            if (err) {
                reject(err)
                res.status(500).json(err);
            } else {
                getTheme(result.insertId)
                .then(theme => {
                    resolve(theme)
                })
                .catch(reject)
            }
        })
    })
}

router.put('/:themeId', (req, res , next) => {
    console.log('in update theme')
    var theme = req.body

    let organizationID = req.get("organizationID")
    console.log(organizationID)

    theme.organization_id = organizationID
    putTheme(theme)
    .then(theme => {
        res.status(200).json(theme);
    })
    .catch(err => {
        res.status(500).json(err);
    })

})

router.put('/', (req, res , next) => {
    console.log('in update theme')
    var object = req.body

    let organizationID = req.get("organizationID")
    console.log(organizationID)

    object.map(theme => theme.organization_id = organizationID)
    Promise.all(object.map( theme => putTheme(theme) ))
    .then(themes => {
        res.status(200).json(themes);
    })
    .catch(err => {
        res.status(500).json(err);
    })

})

function putTheme(theme) {
    return new Promise((resolve, reject) => {
        db.query(`UPDATE theme SET ? WHERE id = ${theme.id}`, [theme], (err, result) => {
            if (err) {
                reject(err)
            } else {
                getTheme(theme.id)
                .then(theme => {
                    resolve(theme)
                })
                .catch(reject)
            }
        })
    })
   
}

function getTheme(themeId) {

    return new Promise((resolve, reject) => {
        let sqlTheme = `SELECT * FROM theme WHERE id=${themeId}`
        db.query(sqlTheme, (err, result) => {
            if (err) {
                reject(err)
            } else if (result.length == 0) {
                resolve()
            } else {
                resolve(result[0])
            }
        })
    })
    
}

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
        getTheme(themeId)
        .then(theme => {
            res.status(200).json(theme)
        })
        .catch(err => {
            res.status(500).json(err)
        })
    });
});

router.delete('/', (req, res , next) => {

    let themes = req.body

    var deleteThemes = function(themes) {
        return new Promise((resolve, reject) => {
            Promise.all(themes.map(theme => deleteTheme(theme)))
            .then(themes => {
                resolve(themes)
            })
            .catch(err => {
                reject(err)
            })
        })
    }
    
    deleteThemes(themes)
    .then(themes => {
        res.status(200).json(themes)
    })
    .catch(err => {
        res.status(500).json(err)
    })
});

function deleteTheme(theme) {
    let date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
    return new Promise((resolve, reject) => {    
        db.query(`UPDATE theme SET deletedAt = "${date}" WHERE id = ${theme.id}`, (err, result) => {
            if (err) {
                reject(err)
            }
            console.log('successfully deleted theme');
            getTheme(theme.id)
            .then(resolve)
            .catch(reject)
        })
    })
}

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