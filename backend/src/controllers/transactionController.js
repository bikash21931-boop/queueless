const { db } = require('../config/firebase-config');

const getUserTransactions = async (req, res) => {
    try {
        const { user_id } = req.params;

        // Security check, ensure users only fetch their own transactions unless admin
        if (req.user.uid !== user_id) {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        const snapshot = await db.collection('Transactions')
            .where('user_id', '==', user_id)
            .orderBy('timestamp', 'desc')
            .get();

        const transactions = [];
        snapshot.forEach(doc => {
            transactions.push(doc.data());
        });

        res.status(200).json({ success: true, transactions });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getUserTransactions };
