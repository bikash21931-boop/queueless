const { db } = require('../config/firebase-config');
const crypto = require('crypto');
const User = require('../models/User');

const processPayment = async (req, res) => {
    try {
        const { items, total_price } = req.body;
        const user_id = req.user.uid;

        // Hackathon Demo: Firebase is unconfigured locally, so we will trust the
        // frontend's calculated `total_price` to bypass the 'No Project Id' error.
        const calculatedTotal = parseFloat(total_price) || 0;

        // 1. Add to user's MongoDB spentThisMonth budget tracker
        // Using MongoDB's User Model (which is correctly connected)
        let earnedCoins = 0;
        const user = await User.findById(user_id);
        if (user) {
            user.spentThisMonth = (user.spentThisMonth || 0) + calculatedTotal;
            earnedCoins = Math.floor(calculatedTotal / 100);
            user.coins = (user.coins || 0) + earnedCoins;
            await user.save();
        }

        // 2. Mock payment success & receipt generation (without saving to Firebase)
        const transaction_id = `TXN_MOCK_${Date.now()}`;
        const receipt_qr = crypto.createHash('sha256').update(`${transaction_id}-${user_id}-${Date.now()}`).digest('hex');

        // Note: For a real app, this is where we would securely save the transaction
        // to Firestore `db.collection('Transactions')` and deduct stock. Skipping 
        // to prevent Firebase errors on the user's local unconfigured machine.

        res.status(200).json({
            success: true,
            transaction_id,
            receipt_qr,
            message: `Dummy Payment successful (Earned ${earnedCoins} coins!)`,
            calculatedTotal,
            earnedCoins
        });
    } catch (error) {
        console.error('Payment processing error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { processPayment };
