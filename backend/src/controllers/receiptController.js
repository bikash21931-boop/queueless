const Transaction = require('../models/Transaction');

const verifyReceipt = async (req, res) => {
    try {
        const { receipt_qr } = req.body;

        const transaction = await Transaction.findOne({ receipt_qr });

        if (!transaction) {
            return res.status(400).json({ success: false, valid: false, message: 'Invalid receipt QR' });
        }

        if (transaction.payment_status === 'COMPLETED') {
            await Transaction.findByIdAndUpdate(transaction._id, {
                payment_status: 'VERIFIED', // or add an exit_status field if preferred
                timestamp: new Date()
            });

            return res.status(200).json({ success: true, valid: true, message: 'Exit approved' });
        } else {
            return res.status(400).json({ success: false, valid: false, message: 'Payment not completed or already verified' });
        }

    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

const getUserReceipts = async (req, res) => {
    try {
        const user_id = req.user.uid || req.user._id.toString();

        const transactions = await Transaction.find({ user_id })
            .sort({ timestamp: -1 });

        res.status(200).json({ success: true, receipts: transactions });
    } catch (error) {
        console.error('Fetch receipts error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { verifyReceipt, getUserReceipts };
