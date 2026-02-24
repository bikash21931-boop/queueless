const { db } = require('../config/firebase-config');
const crypto = require('crypto');

const processPayment = async (req, res) => {
    try {
        const { items, total_price } = req.body;
        const user_id = req.user.uid;

        // Note: For a real app, integrate Stripe or Razorpay here.
        // For hackathon/demo, we mock the payment processing logically.

        // 1. Validate prices from backend to prevent frontend tampering (Fraud Detection)
        let calculatedTotal = 0;
        for (let item of items) {
            const productDoc = await db.collection('Products').doc(item.product_id).get();
            if (productDoc.exists) {
                calculatedTotal += (productDoc.data().price * item.quantity);
            }
        }

        // Allow minimal floating point variance, otherwise exact match required
        if (Math.abs(calculatedTotal - total_price) > 0.01) {
            return res.status(400).json({ success: false, message: 'Price mismatch detected. Fraud protection triggered.' });
        }

        // 2. Mock payment success
        const transaction_id = `TXN_${Date.now()}`;

        // 3. Generate a secure receipt QR string
        const receipt_qr = crypto.createHash('sha256').update(`${transaction_id}-${user_id}-${Date.now()}`).digest('hex');

        // 4. Record transaction
        const transactionRef = db.collection('Transactions').doc(transaction_id);
        await transactionRef.set({
            transaction_id,
            user_id,
            items,
            total_price: calculatedTotal,
            payment_status: 'COMPLETED',
            receipt_qr,
            timestamp: new Date()
        });

        // 5. Deduct Stock
        for (let item of items) {
            const productRef = db.collection('Products').doc(item.product_id);
            // Note: in high concurrency use Firestore transactions
            const pDoc = await productRef.get();
            if (pDoc.exists) {
                await productRef.update({ stock: Math.max(0, pDoc.data().stock - item.quantity) });
            }
        }

        res.status(200).json({ success: true, transaction_id, receipt_qr, message: 'Payment successful' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { processPayment };
