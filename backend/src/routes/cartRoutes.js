const express = require('express');
const router = express.Router();
const { addToCart } = require('../controllers/cartController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/add', verifyToken, addToCart);

module.exports = router;
