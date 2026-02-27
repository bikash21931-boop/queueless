const { admin } = require('../config/firebase-config');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const verifyToken = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            token = req.headers.authorization.split(' ')[1];

            // Decode token
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

            // MongoDB User Lookup
            const user = await User.findById(decoded.id).select('-password');
            if (user) {
                req.user = user;
                req.user.uid = user._id.toString(); // For compatibility with Firebase-oriented code
                return next();
            }
        } catch (error) {
            console.error('JWT Verification Error:', error);
            return res.status(401).json({ error: 'Not authorized, token failed' });
        }
    }

    // Demo Fallback: Bypass if no token provided (useful for Postman testing)
    // Note: In strict production, this block should return 401 instead of a mock.
    req.user = {
        uid: 'mock_user_123',
        _id: 'mock_user_123',
        email: 'mock@example.com'
    };
    next();
};

module.exports = { verifyToken };
