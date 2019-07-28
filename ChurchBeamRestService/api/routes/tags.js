const express = require('express');
const router = express.Router();
const print = require('../util/print')
const TagsClass = require('../util/tagsClass')

var db = require('../util/db');

// GET — retrieve a particular resource’s object or list all objects
// POST — create a new resource’s object
// PATCH — make a partial update to a particular resource’s object
// PUT — completely overwrite a particular resource’s object
// DELETE — remove a particular resource’s object

router.get('/', (req, res , next) => {
    print.print('in get tags all for org')
    let organizationId = req.get("organizationId")
    print.print('orgid', organizationId)
    let after = req.query.updatedsince

    if (organizationId) {
        TagsClass.getTagsForOrganization(organizationId)
        .then(tags => {
            print.print(tags)
            res.status(200).json(tags)
        })
        .catch(err => {
            res.status(500).json(err)
        })
    } else {
        res.status(400).json({
            error: "No organization id"
        })
    }
})

router.get('/:tagId', (req, res , next) => {

    let tagId = req.params.tagId
 
    if (!tagId) {
        res.status(400).json({
            error: "No correct tag identifier send"
        })
    }

    TagsClass.get(tagId)
    .then(tag => {
        print.print('tag returned: ', tag)
        res.status(200).json([tag])
    })
    .catch(err => {
        res.status(500).json(err)
    })
   
})

router.post('/', (req, res , next) => {

    var tags = req.body
    print.print('post tag ---------------------------------------', tags)

    let organizationId = req.get("organizationId")
    print.print('orgid', organizationId)

    tags.map(tag => delete tag.id)
    tags.map(tag => tag.organization_id = organizationId)

    Promise.all(tags.map(tag => TagsClass.postTag(tag)))
    .then(tags => {
        print.print('in result function ----------------------', tags)
        res.status(201).json(tags)
    })
    .catch(err => {
        print.print('in err function ----------------------', err)
        res.status(500).json(err)
    })

})

router.put('/', (req, res , next) => {
    console.log('in update tag')
    const tags = req.body;

    let organizationId = req.get("organizationId")
    print.print('orgid', organizationId)
    tags.map(tag => tag.organization_id = organizationId)

    Promise.all(tags.map(tag => TagsClass.putTag(tag)))
    .then(tags => {
        print.print('in put tag 201', tags)
        res.status(201).json(tags)
    })
    .catch(err => {
        print.print('in put tag 500', err)
        res.status(500).json(err)
    })
})

router.delete('/', (req, res , next) => {
    console.log('in delete tag')
    const tags = req.body

    Promise.all(tags.map(tag => TagsClass.deleteTag(tag)))
    .then(tags => {
        print.print('in put tag 201', tags)
        res.status(201).json(tags)
    })
    .catch(err => {
        print.print('in put tag 500', err)
        res.status(500).json(err)
    })
    
})

module.exports = router;