const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    storeId: {
        type: String,
        required: [true, 'Store ID is required to distinguish products between Dmart, Zudio, etc.'],
        index: true,
        enum: ['dmart', 'zudio'], // Enforce our two stores
        lowercase: true,
    },
    qr_code: {
        type: String,
        required: [true, 'QR Code is required'],
        index: true,
    },
    name: {
        type: String,
        required: [true, 'Product name is required'],
    },
    price: {
        type: Number,
        required: [true, 'Product price is required'],
        min: 0,
    },
    imageUrl: {
        type: String,
        default: '',
    },
    category: {
        type: String,
        default: 'General',
    },
}, { timestamps: true });

// A qr_code should be unique ONLY within its specific store
productSchema.index({ storeId: 1, qr_code: 1 }, { unique: true });

const Product = mongoose.model('Product', productSchema);
module.exports = Product;
