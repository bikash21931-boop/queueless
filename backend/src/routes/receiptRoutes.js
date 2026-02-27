const express = require('express');
const router = express.Router();
const { verifyReceipt, getUserReceipts } = require('../controllers/receiptController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/verify', verifyToken, verifyReceipt);
router.get('/history', verifyToken, getUserReceipts);

module.exports = router;
