const express = require('express');
const router = express.Router();
const SongServiceClass = require('../util/songServiceClass')
const print = require('../util/print')
// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object


router.get('/:songServiceId', (req, res , next) => {
    const songServiceId = req.params.songServiceId
    SongServiceClass.get(songServiceId)
    .then(settings => {
        res.status(200).json(settings)
    })
    .catch(err => { res.status(500).json({
        error: err
    })})
})

router.get('/', (req, res , next) => {
    const organizationId = req.get("organizationId")
    SongServiceClass.getForOrganization(organizationId)
    .then(settings => {
        res.status(200).json(settings)
    })
    .catch(err => { res.status(500).json({
        error: err
    })})
})

router.post('/', (req, res , next) => {
    const organizationId = req.get("organizationId")
    let newSongServiceSettings = req.body[0]
    print.print('newSongservice', newSongServiceSettings)
    if (newSongServiceSettings.id) {
        delete newSongServiceSettings.id
    }
    if (newSongServiceSettings.createdAt) {
        delete newSongServiceSettings.createdAt
    }    
    if (newSongServiceSettings.updatedAt) {
        delete newSongServiceSettings.updatedAt
    }
    newSongServiceSettings.organization_id = organizationId
    SongServiceClass.post(newSongServiceSettings, organizationId)
    .then(settings => {
        res.status(200).json(settings)
    })
    .catch(err => { 
        res.status(500).json({error: errv})
    })
})

router.put('/', (req, res , next) => {
        const organizationId = req.get("organizationId")
        const songServiceSettings = req.body
        SongServiceClass.put(songServiceSettings, organizationId)
        .then(settings => {
            res.status(200).json(settings)
        })
        .catch(err => { res.status(500).json({
            error: err
        })})
})

router.delete('/:songServiceId', (req, res , next) => {
    const songServiceId = req.params.songServiceId
    SongServiceClass.delete(songServiceId)
    .then(settings => {
        res.status(200).json(settings)
    })
    .catch(err => { res.status(500).json({
        error: err
    })})
})

module.exports = router;