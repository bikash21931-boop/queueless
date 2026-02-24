const { db } = require('../config/firebase-config');

const addToCart = async (req, res) => {
    try {
        const { product_id, quantity } = req.body;
        const user_id = req.user.uid;

        // In a real sophisticated system, we might store active carts in Firestore
        // For a lighter demo/MVP, cart state is primarily local, but this endpoint
        // can validate items being added or log scanner metrics.

        // Validate product exists
        const productRef = db.collection('Products').doc(product_id);
        const productDoc = await productRef.get();

        if (!productDoc.exists) {
            return res.status(404).json({ success: false, message: 'Product not found' });
        }

        const productData = productDoc.data();

        // Check stock
        if (productData.stock < quantity) {
            return res.status(400).json({ success: false, message: 'Insufficient stock' });
        }

        res.status(200).json({ success: true, message: 'Product validated for cart', product: productData });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { addToCart };
