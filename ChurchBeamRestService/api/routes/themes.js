const express = require('express');
const router = express.Router();
const mysql = require('mysql');

const db = mysql.createConnection({
    host    : 'localhost',
    user    : 'root',
    password: 'Leovanderzee1986',
    database: 'localhostchurchbeam'
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
    let sqlAllThemes = `SELECT * FROM theme`
    db.query(sqlAllThemes, (err, result) => {
        if(err) throw err;
        res.status(200).json({
            themes: result
        });
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

    var newTheme = req.body;
    var title = req.body.title;
    console.log(`posted theme: ${title}`)

    let sql = 'INSERT INTO theme SET ?';
    db.query(sql, newTheme, (err, result) => {
        if (err) throw err;
        getTheme(result.insertId, callback => {
            res.status(200).json({
                theme: callback
            });
        })
    });

});

router.put('/:themeId', (req, res , next) => {
    console.log('in update theme')
    var theme = req.body;

    db.query(`UPDATE theme SET ? WHERE id = ${req.params.themeId}`, [theme], (err, result) => {
        if (err) throw err;
        console.log('successfully updated theme');
        getTheme(req.params.themeId, callback => {
            res.status(200).json({
                theme: callback
            });
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

    let deleteTheme = 'DELETE FROM theme WHERE id = ? '
    Promise.all(queryDb(deleteTheme, [themeId])).then(function() {
        console.log('Theme deleted')
        res.status(200).json({})
    })
    // query(deleteTheme, [themeId], callback => {
    //     console.log('theme deleted');
    //     res.status(200).json({

    //     });
    // });
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
}

// function query(query, ids, callback) {
//     var totalResult = [];
//     var totalObjectsToDelete = ids.length;
//     var totalDeleted = 0;



//     for (var id of ids) {
//         db.query(query, id, (err, result) => {
//             if(err) throw err;
//             totalDeleted += 1;
//             Array.prototype.push.apply(totalResult, result);

//             if (totalDeleted == totalObjectsToDelete) {
//                 console.log(totalResult);
//                 callback(totalResult);
//             }
//         });
//     };
// };

module.exports = router;

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
// 	"isLyricsBold" : "0",
// 	"isLyricsItalic" : "0",
// 	"isLyricsUnderlined" : "0",
// 	"isTitleBold" : "0",
// 	"isTitleItalic" : "0",
// 	"isTitleUnderlined" : "0",
// 	"lyricsAlignmentNumber" : "0",
// 	"lyricsBorderColor" : "FFFFFF",
// 	"lyricsBorderSize" : "0",
// 	"lyricsFontName" : "Helvetica Neu",
// 	"lyricsTextColor" : "FFFFFF",
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