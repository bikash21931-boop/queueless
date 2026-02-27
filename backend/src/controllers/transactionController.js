const Transaction = require('../models/Transaction');

const getUserTransactions = async (req, res) => {
    try {
        const { user_id } = req.params;

        // Security check
        if (req.user.uid !== user_id && req.user._id.toString() !== user_id) {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        // Fetch from MongoDB instead of Firebase
        const transactions = await Transaction.find({ user_id })
            .sort({ timestamp: -1 });

        res.status(200).json({ success: true, transactions });
    } catch (error) {
        console.error('Fetch Transactions Error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getUserTransactions };
