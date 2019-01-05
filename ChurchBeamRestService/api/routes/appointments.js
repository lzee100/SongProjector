const express = require('express');
const router = express.Router();

router.get('/', (req, res , next) => {

    var jsonArray = [];
    var i = 1;
    do {
        console.log('in do');
        var soort = 'knippen';
        var hour = i.toString();
        var medewerker = 'Roewin Smit';
        var code = "ABCD";
        if (i % 2 == 0) {
            medewerker = 'Steven Smit';
        }
        hour += ':00';
        if(i % 2 == 0) {
            soort = "wassen";
        }
            jsonArray.push({
            tijd : hour,
            soort: soort,
            medewerker: medewerker,
            code: code
        });
        console.log(jsonArray[i]);
     i++;
    }
    while (i < 5);


    
    res.status(200).json({
        message: 'appointments are fetched',
        appointments: jsonArray

    });
});



module.exports = router;