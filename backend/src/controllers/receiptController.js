const { db } = require('../config/firebase-config');

const verifyReceipt = async (req, res) => {
    try {
        const { receipt_qr } = req.body;

        // The physical exit gate sends the scanned QR here

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
            // Optional: Mark receipt as 'USED' to prevent multi-exit with same QR
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

module.exports = { verifyReceipt };
