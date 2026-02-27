const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Generate JWT Token
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'fallback_secret', {
        expiresIn: process.env.JWT_EXPIRES_IN || '30d',
    });
};

const register = async (req, res) => {
    try {
        const { firstName, lastName, phone, email, password } = req.body;

        if (!firstName || !lastName || !phone || !email || !password) {
            return res.status(400).json({ error: 'Please provide all required fields' });
        }

        // Check if user exists
        const userExists = await User.findOne({
            $or: [{ email: email.toLowerCase() }, { phone }]
        });

        if (userExists) {
            return res.status(400).json({ error: 'User with this email or phone already exists' });
        }

        // Create User
        const user = await User.create({
            firstName,
            lastName,
            phone,
            email,
            password
        });

        if (user) {
            res.status(201).json({
                uid: user._id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                phone: user.phone,
                monthlyBudget: user.monthlyBudget,
                spentThisMonth: user.spentThisMonth,
                coins: user.coins,
                token: generateToken(user._id),
            });
        }
    } catch (error) {
        console.error('Registration Error:', error);
        res.status(500).json({ error: error.message || 'Server Error during registration' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Please provide email and password' });
        }

        // Find user & include password field for checking
        const user = await User.findOne({ email: email.toLowerCase() }).select('+password');

        if (user && (await user.matchPassword(password))) {
            res.json({
                uid: user._id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                phone: user.phone,
                monthlyBudget: user.monthlyBudget,
                spentThisMonth: user.spentThisMonth,
                coins: user.coins,
                token: generateToken(user._id),
            });
        } else {
            res.status(401).json({ error: 'Invalid email or password' });
        }
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ error: 'Server Error during login' });
    }
};

const updateBudget = async (req, res) => {
    try {
        const { monthlyBudget } = req.body;

        // Ensure user is authenticated via middleware
        const user = await User.findById(req.user._id);

        if (user) {
            user.monthlyBudget = monthlyBudget || 0;
            const updatedUser = await user.save();

            res.json({
                success: true,
                monthlyBudget: updatedUser.monthlyBudget,
                spentThisMonth: updatedUser.spentThisMonth,
                message: "Budget updated successfully"
            });
        } else {
            res.status(404).json({ success: false, message: 'User not found' });
        }
    } catch (error) {
        console.error('Update Budget Error:', error);
        res.status(500).json({ success: false, message: 'Server Error updating budget' });
    }
};

module.exports = {
    register,
    login,
    updateBudget
};
