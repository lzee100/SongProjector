
class DataBaseDateClass {

    static getDateForDataBase(date) {
        return date.toISOString().replace(/T/, ' ').replace(/\..+/, '')
    }

}

module.exports = DataBaseDateClass
        
