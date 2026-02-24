const { admin } = require('../config/firebase-config');

const verifyToken = async (req, res, next) => {
    // Demo Fallback: Bypass real Firebase token verification
    // Since the Flutter app is running with a Mock Auth Provider,
    // we inject a mock user into the request instead of validating a real JWT.
    req.user = {
        uid: 'mock_user_123',
        email: 'mock@example.com'
    };
    next();
};

module.exports = { verifyToken };
