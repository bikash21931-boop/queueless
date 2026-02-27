const { db } = require('../config/firebase-config');

const verifyReceipt = async (req, res) => {
    try {
        const { receipt_qr } = req.body;

        const snapshot = await db.collection('Transactions')
            .where('receipt_qr', '==', receipt_qr)
            .get();

        if (snapshot.empty) {
            return res.status(400).json({ success: false, valid: false, message: 'Invalid receipt QR' });
        }

        let transaction;
        snapshot.forEach(doc => {
            transaction = doc.data();
        });

        if (transaction.payment_status === 'COMPLETED') {
            await db.collection('Transactions').doc(transaction.transaction_id).update({
                exit_status: 'VERIFIED',
                exit_timestamp: new Date()
            });

            return res.status(200).json({ success: true, valid: true, message: 'Exit approved' });
        } else {
            return res.status(400).json({ success: false, valid: false, message: 'Payment not completed' });
        }

    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

const getUserReceipts = async (req, res) => {
    try {
        const user_id = req.user.uid;

        const snapshot = await db.collection('Transactions')
            .where('user_id', '==', user_id)
            // .orderBy('timestamp', 'desc') // Firebase requires an index for orderBy occasionally, doing naive for hackathon
            .get();

        const receipts = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            if (data.timestamp && data.timestamp.toDate) {
                data.timestamp = data.timestamp.toDate().toISOString();
            }
            receipts.push(data);
        });

        // Manual sort to avoid index creation requirement in firebase console right now
        receipts.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

        res.status(200).json({ success: true, receipts });
    } catch (error) {
        console.error('Fetch receipts error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { verifyReceipt, getUserReceipts };
