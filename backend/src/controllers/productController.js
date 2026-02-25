const Product = require('../models/Product');

const getProductByQR = async (req, res) => {
    try {
        const { qr_code } = req.params;
        const { storeId } = req.query;

        if (!storeId) {
            return res.status(400).json({ success: false, message: 'storeId query parameter is required' });
        }

        // Query MongoDB using both the QR code and the contextual Store selection
        const product = await Product.findOne({
            qr_code: qr_code,
            storeId: storeId.toLowerCase()
        });

        if (!product) {
            return res.status(404).json({ success: false, message: 'Product not found in this store' });
        }

        res.status(200).json({ success: true, product });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getProductByQR };
