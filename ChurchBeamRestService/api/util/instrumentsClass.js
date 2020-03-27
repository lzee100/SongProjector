var db = require('../util/db')

class InstrumentsClass {

    static getInstruments(clusterId) {
        return new Promise((resolve, reject) => {
            var sql = `SELECT I.* FROM instrument as I inner join instrumentHasClusters as IC on I.id = IC.instrument_id WHERE IC.cluster_id =${clusterId}`
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    resolve(result)
                }
            })
        })
    }

    static getInstrumentOnId(instrumentId) {
        return new Promise((resolve, reject) => {
            var sql = `SELECT * FROM instrument WHERE id =${instrumentId}`
            db.query(sql, (err, result) => {
                if(err) {
                    reject(err)
                } else {
                    resolve(result[0])
                }
            })
        })
    }

    static postInstrument(instrument, clusterId) {

        let insertInstrument = function() {
            return new Promise((resolve, reject) => {
                let sql = `INSERT INTO instrument SET ?`
                db.query(sql, [instrument], (err, result) => {
                    if(err) {
                        reject(err)
                    } else {
                        resolve(result.insertId)
                    }
                })
            })
        }

        let insertInstrumentHasCluster = function(instrumentId) {
            return new Promise((resolve, reject) => {
                InstrumentsClass.postInstrumentHasClusterIfNeeded(instrumentId, clusterId)
                .then(resolve)
                .catch(reject)
            })
        }

        return new Promise((resolve, reject) => {
            insertInstrument()
            .then(insertInstrumentHasCluster)
            .then(resolve)
            .catch(reject)
        })

    }

    static postInstrumentHasClusterIfNeeded(instrumentId, clusterId) {

        let checkInstrumentExists = function() {
            return new Promise((resolve, reject) => {
                let sql = `SELECT * from instrumentHasClusters where instrument_id = ${instrumentId} AND cluster_id = ${clusterId}`
                db.query(sql, (err, result) => {
                    if(err) {
                        reject(err)
                    } else {
                        if (result.length > 0) {
                            resolve(result[0])
                        } else {
                            resolve()
                        }
                    }
                })
            })
        }

        let insertInstrumentHasClusterIfNeeded = function(instrumentHasClusters) {
            return new Promise((resolve, reject) => {
                if (instrumentHasClusters) {
                    resolve(instrumentHasClusters)
                } else {
                    let instrumentHasClusters = {
                        cluster_id: clusterId,
                        instrument_id: instrumentId
                    }
                    let sql = `INSERT INTO instrumentHasClusters SET ?`
                    db.query(sql, [instrumentHasClusters], (err, result) => {
                        if(err) {
                            reject(err)
                        } else {
                            resolve(instrumentHasClusters)
                        }
                    })
                }
            })
        }

        return new Promise((resolve, reject) => {
            checkInstrumentExists()
            .then(insertInstrumentHasClusterIfNeeded)
            .then(resolve)
            .catch(reject)
        })
    }

}

module.exports = InstrumentsClass