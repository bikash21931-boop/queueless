const mockDatabase = [
    {
        id: "mock_123",
        qr_code: "mock_123",
        name: "Premium Organic Coffee Roast",
        price: 14.99,
        imageUrl: "https://images.unsplash.com/photo-1559525839-b184a4d698c7?auto=format&fit=crop&q=80&w=200",
        category: "Beverages"
    },
    {
        id: "mock_456",
        qr_code: "mock_456",
        name: "Artisan Sourdough Bread",
        price: 6.50,
        imageUrl: "https://images.unsplash.com/photo-1589367920969-ab8e050eb0e9?auto=format&fit=crop&q=80&w=200",
        category: "Bakery"
    }
];

const getProductByQR = async (req, res) => {
    try {
        const { qr_code } = req.params;

        // Query our "Database"
        const product = mockDatabase.find(p => p.qr_code === qr_code);

        if (!product) {
            return res.status(404).json({ success: false, message: 'Product not found in database' });
        }

        // Simulate database latency
        await new Promise(resolve => setTimeout(resolve, 800));

        res.status(200).json({ success: true, product });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getProductByQR };
