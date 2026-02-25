require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('./src/models/Product');
const connectDB = require('./src/config/db');

// Sample Product Data representing two stores
const products = [
    {
        storeId: 'dmart',
        qr_code: 'item_101',
        name: 'Premium Organic Coffee Roast',
        price: 14.99,
        imageUrl: 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?auto=format&fit=crop&q=80&w=200',
        category: 'Beverages'
    },
    {
        storeId: 'dmart',
        qr_code: 'item_102',
        name: 'Artisan Sourdough Bread',
        price: 6.50,
        imageUrl: 'https://images.unsplash.com/photo-1589367920969-ab8e050eb0e9?auto=format&fit=crop&q=80&w=200',
        category: 'Bakery'
    },
    {
        storeId: 'zudio',
        qr_code: 'item_201',
        name: 'Classic White Graphic Tee',
        price: 9.99,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=200',
        category: 'Apparel'
    },
    {
        storeId: 'zudio',
        qr_code: 'item_202',
        name: 'Denim Vintage Jacket',
        price: 49.99,
        imageUrl: 'https://images.unsplash.com/photo-1576995810559-fb01c107beed?auto=format&fit=crop&q=80&w=200',
        category: 'Apparel'
    }
];

const seedDatabase = async () => {
    try {
        await connectDB();

        // Clear out old data
        await Product.deleteMany();
        console.log('Old Products removed');

        // Insert new dummy data
        await Product.insertMany(products);
        console.log('Database Seeded Successfully with Dmart & Zudio products!');

        process.exit();
    } catch (error) {
        console.error(`Error Seeding DB: ${error.message}`);
        process.exit(1);
    }
};

seedDatabase();
