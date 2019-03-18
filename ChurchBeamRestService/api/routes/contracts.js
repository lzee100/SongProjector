const express = require('express')
const router = express.Router()
const print = require('../util/print')
var contractNL = require('../util/ContractNLClass')

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {
    
    print.print('in user init')

    let locale = req.query.locale

    if (locale == "NL") {
        
        let free = contractNL.getFree()
        let beam = contractNL.getBeam()
        let song = contractNL.getSong()

        let contracts = [free, beam, song]
        res.status(200).json(contracts)
    }

})

module.exports = router;