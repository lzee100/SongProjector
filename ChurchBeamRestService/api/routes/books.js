const express = require('express')
const router = express.Router()
var db = require('../util/db');
var print = require('../util/print');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {
    let sqlFullBook = `SELECT * FROM book`
    db.query(sqlFullBook, (err, result) => {
        if(err) throw err
        res.status(200).json({
            book: result
        })
    })
})

router.get('/:bookId', (req, res , next) => {
    getBookWithChaptersAndVerses(req.params.bookId).then(function(book) {
        res.status(200).json({
            book: book
        })
    }).catch(function(err) {
        res.status(404).json({
            Error: err
        })
    })
})

router.post('/', (req, res , next) => {

    var newBook = req.body
    var newChapters = newBook.chapters

    delete newBook.chapters

    var insertBookPromise = function() {
        return new Promise ((resolve, reject) => {
            let sql = 'INSERT INTO book SET ?'
            db.query(sql, newBook, (err, result) => {
            if(err) {
                reject(err)
            } else {
                resolve(result.insertId)
            }
            })
        })
    }

    var insertChaptersPromise = function(bookId) {

        return new Promise ((resolve, reject) => {
            for (var chapter of newChapters) {
                chapter.book_id = bookId
            }
    
            var chaptersArray = []
            for (var chapter of newChapters) {
                chaptersArray.push([parseInt(chapter.number), chapter.book_id])
            }
    
            var sqlChapterInsert = 'INSERT INTO chapter (number, book_id) VALUES ?'
            db.query(sqlChapterInsert, [chaptersArray], (err, result) => {
                if (err) {
                    reject(err)
                } else {                
                var rowIds = []
                for (var i = result.insertId; i < result.insertId + result.affectedRows; i++) {
                rowIds.push(i)
                }
                var i = 0
                for (var chapter of newChapters) {
                    chapter.id = rowIds[i]
                    i++
                }
                    resolve([bookId, newChapters])
                }
            })
        })
    }

    var insertVerses = function(bookId, versProperties) {
        return new Promise((resolve, reject) => {
            var sqlVersesInsert = 'INSERT INTO vers (number, content, chapter_id, chapter_book_id) VALUES ?'
            db.query(sqlVersesInsert, [versProperties], (err, result) => {
                if (err) {
                    reject()
                } else {
                    resolve(bookId)
                }
            })
        })
    }

    var insertVersesPromise = function(bookAndChapters) {
        let allVersesToInsert = bookAndChapters[1].map(chapter => { 
            return chapter.verses.map(vers => [parseInt(vers.number), vers.text, chapter.id, chapter.book_id])
        })

        return new Promise((resolve, reject) => {
            Promise.all(allVersesToInsert.map(versDetails => insertVerses(bookAndChapters[0], versDetails)))
            .then(resolve(bookAndChapters[0]))
            .catch(reject(err))
        })
    }

    insertBookPromise()
    .then(insertChaptersPromise)
    .then(insertVersesPromise)
    .then(getBookWithChaptersAndVerses)
    .then(result => {
        res.status(200).json({
            books: [result]
        })
    }).catch(function(err) {
        throw err
    })
})

router.put('/:bookId', (req, res , next) => {
    console.log('in update book')
    var bookId = req.params.bookId
    var updatedBook = req.body.title

    var updateBook = function(bookId, book) {
         return new Promise((resolve, reject) => {
            db.query(`UPDATE book SET title = ? WHERE id = ${bookId}`, [book], (err, result) => {
                if (err) {
                    reject(err)
                } else {
                    resolve(bookId)
                }
            })
        })
    }

    updateBook(bookId, updatedBook)
    .then(getBookWithChaptersAndVerses)
    .then(updatedBook => {
        console.log('in updated')
        console.log(updatedBook)
        res.status(200).json({
            books: [updatedBook]
        })
    }).catch(err => {
        console.log('in err')
        res.status(400).json({
            Error: err
        })
    })
})

function getBookWithChaptersAndVerses(bookId) {

    return new Promise( (resolve, reject) => {

        let getBookPromise = function(bookId) {
            return new Promise((resolve, reject) => {
                let sqlFullBook = `SELECT * FROM book WHERE book.id=${bookId}`
                db.query(sqlFullBook, (err, result) => {
                    if (err) {
                        reject(err)
                    } else if (result.length == 0) { // book not found
                        reject('bookNotFound')
                    } else {
                        resolve([bookId, JSON.parse(JSON.stringify(result))[0]])
                    }
                })
            })
        }

        let getChaptersPromise = function(idAndBook) {
            let bookId = idAndBook[0]
            let book = idAndBook[1]
            return new Promise((resolve, reject) => {
                let sqlAllChapters = `SELECT * FROM chapter WHERE book_id=${bookId}`
                db.query(sqlAllChapters, (err, result) => {
                    if (err) {
                        reject(err)
                    } else if (result.length == 0) { // no chapters for this book
                        resolve([bookId, book, []])
                    } else {
                        resolve([bookId, book, JSON.parse(JSON.stringify(result))])
                    }
                })
            })
        }

        let getVersesForChapterPromise = function(idAndBookAndChapters) {
            var book = idAndBookAndChapters[1]
            let chapters = idAndBookAndChapters[2]

            return new Promise((resolve, reject) => {
                Promise.all(chapters.map(chapter => new Promise((resolve, reject) => {
                    let sqlAllVerses = `SELECT * FROM vers WHERE chapter_id=${chapter.id} ORDER BY number`
                    db.query(sqlAllVerses, (err, result) => {
                        if (err) {
                            reject(err)
                        } else {
                            var newChapter = chapter
                            newChapter.verses = JSON.parse(JSON.stringify(result))
                            resolve(newChapter)
                        }
                    })
                }))).then(chapters => {
                    book.chapters = chapters
                    resolve(book)
                }).catch(err => {
                    reject(err)
                })
            })         
        }

        getBookPromise(bookId)
        .then(getChaptersPromise)
        .then(getVersesForChapterPromise)
        .then(function(book) {
            resolve(book)
        }).catch(function(err) {
            reject(err)
        })
        
    })

}

router.delete('/:bookId', (req, res , next) => {
    console.log('deletedbook')
    // url looks like: "localhost:3000/books/123&?deleteall=true" 
    // (method = DELETE)
    // parameters in url:
    // bookId: 123 for example
    // deleteAll: true or false
    let bookId = req.params.bookId

    let deleteBook = function(bookId) {
        return new Promise((resolve, reject) => {
            db.query("DELETE FROM book WHERE id = ?", bookId, (err, result) => {
                if (err) {
                    console.log('in err')
                    console.log(err)
                    reject(err)
                } else {
                    resolve()
                }
            })
        })
    }

    deleteBook(bookId)
    .then(function() {
        console.log('success')
        res.status(200).json({
        })
    })
    .catch(function(result) {
        console.log(result)
        res.status(500).json({
            Error: err
        })
    })
})

module.exports = router

// for posting add this in body
// {
//     "title":"GENESIS",
//     "chapters":[
//         {
//             "number":"1",
//             "verses":[
//                 {
//                     "number":"1",
//                     "text":"dit is de eerste vers van het eerste hoofdstuk"
//                 },
//                 {
//                     "number":"2",
//                     "text":"dit is de tweede vers van het eerste hoofdstuk"
//                 }
//             ]
//         },
//         {
//             "number":"2",
//             "verses":[
//                 {
//                     "number":"1",
//                     "text":"dit is de eerste vers van het tweede hoofdstuk"
//                 },
//                 {
//                     "number":"2",
//                     "text":"dit is de tweede vers van het tweede hoofdstuk"
//                 }
//             ]
//         },
//         {
//             "number":"3",
//             "verses":[
//                 {
//                     "number":"1",
//                     "text":"dit is de eerste vers van het derde hoofdstuk"
//                 },
//                 {
//                     "number":"2",
//                     "text":"dit is de tweede vers van het derde hoofdstuk"
//                 }
//             ]
//         },
//         {
//             "number":"4",
//             "verses":[
//                 {
//                     "number":"1",
//                     "text":"dit is de eerste vers van het vierde hoofdstuk"
//                 },
//                 {
//                     "number":"2",
//                     "text":"dit is de tweede vers van het vierde hoofdstuk"
//                 }
//             ]
//         }
//     ]
// }