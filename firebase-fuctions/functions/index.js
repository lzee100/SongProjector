/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// RUN IN TERMINAL TO START: firebase emulators:start
// RUN IN TERMINAL TO START: firebase serve --only functions
// RUN IN TERMINAL: firebase deploy --only functions

const { v4: uuidv4 } = require('uuid');

const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});
var db = admin.firestore();

// The Firebase Admin SDK to access Firestore.
// const { initializeApp } = require("firebase-admin/app");
// const { getFirestore } = require("firebase-admin/firestore");

exports.fetchUniversalClustersWithUID = functions.region('europe-west1').https.onRequest(async (request, response) => {

    const token = request.header('authorization');
    const tokenId = await admin
        .auth()
        .verifyIdToken(token)
        .then(function (decodedToken) {
            var uid = decodedToken.uid;
            return uid;
        })
        .catch(function (error) {
            console.log("error ->", error);
            response.status(500).send({ error: 'Something failed!' })
        });

        var errorValue = "error";
        var translator = {
            getErrorValue : function() {return errorValue;},
            setErrorValue : function(value) {errorValue = value;}
         };
    try {
        let clusters = await GetUniversalClustersUseCase.getUniversalClusters(tokenId, translator);
        response.send({ success: clusters });
    } catch (error) {
        response.status(500).send({ error: errorValue });
    };

});

exports.fetchUser = functions.region('europe-west1').https.onRequest(async (request, response) => {

    const token = request.header('authorization');
    const installToken = request.header('installTokenId');
    const userUID = await admin
        .auth()
        .verifyIdToken(token)
        .then(function (decodedToken) {
            var uid = decodedToken.uid;
            return uid;
        })
        .catch(function (error) {
            console.log("error ->", error);
            response.status(500).send({ error: 'Something failed!' + error })
        });

    try {
        let user = await CreateUserIfNeeded.createUserIfNeeded(userUID, installToken);
        response.send(user);
    } catch (error) {
        response.status(500).send({ error: error });
    };

});

exports.hasNewUniversalClusters = functions.region('europe-west1').https.onRequest(async (request, response) => {

    const token = request.header('authorization');
    const userUID = await admin
    .auth()
    .verifyIdToken(token)
    .then(function (decodedToken) {
        var uid = decodedToken.uid;
        return uid;
    })
    .catch(function (error) {
        console.log("error ->", error);
        response.status(500).send({ error: 'Something failed!' })
    });

    try {
        const hasNewUniversalClusters = await GetUniversalClustersUseCase.hasUniversalClusters(userUID);
        response.send({hasNewUniversalClusters: hasNewUniversalClusters});
    } catch (error) {
        response.status(500).send({ error: errorValue });
    };
});

class CreateUserIfNeeded {

    static async createUserIfNeeded(userUID, installTokenId) {
        const data = await db.collection('users').where('userUID', '==', userUID).get();
        if (data.docs.length > 0) {
            const user = data.docs[0].data();
            let installTokens = user.appInstallTokens.split(",");
            if (!installTokens.includes(installTokenId)) {
                installTokens.push(installTokenId)
            }
            const installTokensString = installTokens.join(",");
            user.appInstallTokens = installTokensString;
            return user;
        } else {
            const id = "CHURCHBEAM" + uuidv4();
            var user = {
                userUID: userUID,
                updatedAt: new Date().getTime(),
                createdAt: new Date().getTime(),
                adminInstallTokenId: installTokenId,
                appInstallTokens: installTokenId,
                sheetTimeOffset: 0,
                id: id
            };
            await db.collection('users').doc(id).set(user);
            return user;
        }
    }

}

class GetUniversalClustersUseCase {

    static async hasUniversalClusters(userUID) {

        const universalUpdatedAt = await this.getUniversalUpdatedAt(userUID);
        let snapshot = await db.collection('universalclusters').where('updatedAt', '>', universalUpdatedAt).get();

        return snapshot.docs.length > 0;
    }

    static async getUniversalClusters(userUID, errorValue) {
        const universalUpdatedAt = await this.getUniversalUpdatedAt(userUID);
        var defaultTheme = await this.createDefaultThemeIfNeeded(userUID);
        let snapshot = await db.collection('universalclusters').where('updatedAt', '>', universalUpdatedAt).get();
        errorValue.setErrorValue("line 152");
        await this.updateUniversalClusters(userUID, snapshot.docs, errorValue);
        errorValue.setErrorValue("line 154")

        const updatedUniversalClusters = snapshot.docs.map(doc => {
            const universalCluster = doc.data();
            const rootID = universalCluster.id;
            universalCluster.userUID = userUID;
            universalCluster.root = rootID;
            universalCluster.theme_id = defaultTheme.id;
            universalCluster.id = "CHURCHBEAM" + uuidv4();
            universalCluster.updatedAt = new Date().getTime();

            const sheets = universalCluster.sheets;
            const instruments = universalCluster.instruments;
            const updatedSheets = sheets.map(sheet => {
                sheet.id = "CHURCHBEAM" + uuidv4();
                sheet.userUID = userUID;
                sheet.createdAt = new Date().getTime();
                sheet.updatedAt = new Date().getTime();
                if (sheet.theme != null) {
                    const theme = sheet.theme;
                    theme.id = "CHURCHBEAM" + uuidv4();
                    theme.userUID = userUID;
                    theme.createdAt = new Date().getTime();
                    theme.updatedAt = new Date().getTime();
                    sheet.theme = theme;
                }
                return sheet
            });
            universalCluster.sheets = updatedSheets;
            errorValue.setErrorValue("line 183");

            const updatedInstruments = instruments.map(instrument => {
                instrument.id = "CHURCHBEAM" + uuidv4();
                instrument.userUID = userUID;
                instrument.createdAt = new Date().getTime();
                instrument.updatedAt = new Date().getTime();
                return instrument
            });
            errorValue.setErrorValue("line 192");

            universalCluster.instruments = updatedInstruments;
            return universalCluster
        })
        errorValue.setErrorValue("line 197");

        await Promise.all(updatedUniversalClusters.map(async (cluster) => {
            await db.collection('clusters').doc(cluster.id).set(cluster);
        }));

        await this.setUniversalUpdatedAt(userUID);
        errorValue.setErrorValue("line 204");

        return updatedUniversalClusters;
    };

    static async updateUniversalClusters(userUID, docs, errorValue) {
        return await Promise.all(docs.map(async (doc) => {
            const clusterData = doc.data();
            let rootId = clusterData.id;
            errorValue.setErrorValue("line 213");
            let userClusters = await db.collection('clusters').where('userUID', '==', userUID).where('root', '==', rootId).get();

            if (userClusters.docs.length > 0) {
                let userCluster = userClusters.docs[0].data();

                var id = doc.id;
                if (userCluster.id == null) {
                    userCluster.id = id
                }

                errorValue.setErrorValue("line 217");
                if (clusterData.rootDeleteDate != null) {
                    errorValue.setErrorValue("line 220");
                    userCluster.deletedAt = clusterData.rootDeleteDate;
                    userCluster.rootDeleteDate = clusterData.rootDeleteDate;
                }
                errorValue.setErrorValue("line 224");
                userCluster.updatedAt = new Date().getTime();

                await db.collection('clusters').doc(userCluster.id).set(userCluster);
                errorValue.setErrorValue("line 228");
                return userCluster;
            }
        }));
    };

    static async createDefaultThemeIfNeeded(userUID) {

        const defaultThemes = await db.collection('themes').where('userUID', '==', userUID).where('isDeletable', "==", 0).get();

        if (defaultThemes.docs.length == 0) {
            const id = "CHURCHBEAM" + uuidv4();
            const defaultTheme = {
                titleTextColor: "000000",
                displayTime: 0,
                isEmptySheetFirst: 0,
                titleBorderSize: 0,
                contentTextSize: 9,
                hasEmptySheet: 0,
                imagePathAWS: null,
                titleFontName: "Avenir",
                isContentItalic: 0,
                title: "Default theme",
                allHaveTitle: 0,
                titleBackgroundColor: null,
                contentBorderSize: 0,
                isDeletable: 0,
                createdAt: new Date().getTime(),
                contentAlignmentNumber: 0,
                titleTextSize: 11,
                contentTextColor: "000000",
                id: id,
                isTitleBold: 0,
                updatedAt: new Date().getTime(),
                backgroundColor: "FFFFFF",
                contentBorderColor: null,
                isContentUnderlined: 0,
                contentFontName: "Avenir",
                titleBorderColor: null,
                backgroundTransparancy: "0.0",
                isContentBold: 0,
                isHidden: 0,
                isTitleItalic: 0,
                isTitleUnderlined: 0,
                titleAlignmentNumber: 0,
                position: 0,
                userUID: userUID
            };
            await db.collection('themes').doc(id).set(defaultTheme);
            return defaultTheme;
        } else {
            return defaultThemes.docs[0].data();
        }
    }

    static async getUniversalUpdatedAt(userUID) {
        const data = await db.collection('universalupdatedat').where('userUID', '==', userUID).get();
        if (data.docs.length > 0) {
            return data.docs[0].data().universalUpdatedAt;
        } else {
            return 1
        }
    }

    static async setUniversalUpdatedAt(userUID) {
        const data = await db.collection('universalupdatedat').where('userUID', '==', userUID).get();
        if (data.docs.length > 0) {
            var uua = data.docs[0].data();
            uua.universalUpdatedAt = new Date().getTime();
            var id = data.docs[0].id;
            if (uua.id == null) {
                uua.id = data.docs[0].id
            }
            await db.collection('universalupdatedat').doc(id).set(uua);
            return uua;
        } else {
            const id = "CHURCHBEAM" + uuidv4();
            var uua = {
                userUID: userUID,
                updatedAt: new Date().getTime(),
                universalUpdatedAt: new Date().getTime(),
                createdAt: new Date().getTime(),
                id: id
            }
            await db.collection('universalupdatedat').doc(id).set(uua);
            return uua;
        }
    }

}
