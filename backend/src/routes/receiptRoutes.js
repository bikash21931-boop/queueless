const express = require('express');
const router = express.Router();
const { verifyReceipt } = require('../controllers/receiptController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/verify', verifyToken, verifyReceipt);

module.exports = router;
