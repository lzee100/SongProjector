

class print {

    static print(text, object) {
        if (object != null) {
            console.log(`${text}`)
            print.json(object)
        } else {
            console.log(text)
        }
    }

    static json(obj) {
        console.log(JSON.stringify(obj, null, 2));
    }

}

module.exports = print