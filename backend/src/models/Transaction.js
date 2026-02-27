const mongoose = require('mongoose');

const transactionItemSchema = new mongoose.Schema({
    product_id: { type: String, required: true },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true }
});

const transactionSchema = new mongoose.Schema({
    transaction_id: {
        type: String,
        required: true,
        unique: true
    },
    user_id: {
        type: String,
        required: true,
        index: true
    },
    total_price: {
        type: Number,
        required: true,
    },
    payment_status: {
        type: String,
        default: 'COMPLETED'
    },
    receipt_qr: {
        type: String,
        required: true
    },
    items: [transactionItemSchema],
    timestamp: {
        type: Date,
        default: Date.now
    }
});

const Transaction = mongoose.model('Transaction', transactionSchema);
module.exports = Transaction;
