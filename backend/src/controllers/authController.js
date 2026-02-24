const { auth, db } = require('../config/firebase-config');

const register = async (req, res) => {
    try {
        const { email, password, name } = req.body;

        // In a real app, FirebaseAuth handles signup securely from client side,
        // but if done via API, we use admin SDK:
        const userRecord = await auth.createUser({
            email,
            password,
            displayName: name,
        });

        // Store additional user details in Firestore
        await db.collection('Users').doc(userRecord.uid).set({
            user_id: userRecord.uid,
            name,
            email,
            created_at: new Date()
        });

        res.status(201).json({ success: true, message: 'User registered', uid: userRecord.uid });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

const login = async (req, res) => {
    // Note: Firebase Auth login usually happens on the client side.
    // This API endpoint could be used to set custom claims or verify login.
    res.status(200).json({ success: true, message: 'Please login via Firebase Client SDK and pass token in Auth header.' });
};

module.exports = { register, login };
