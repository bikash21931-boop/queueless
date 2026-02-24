const express = require('express');
const router = express.Router();
const { getProductByQR } = require('../controllers/productController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.get('/:qr_code', verifyToken, getProductByQR);

module.exports = router;
