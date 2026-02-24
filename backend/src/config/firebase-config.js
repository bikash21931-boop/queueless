const admin = require('firebase-admin');
// In a real app, initialize with serviceAccount credentials
// const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    // credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

module.exports = { admin, db, auth };
