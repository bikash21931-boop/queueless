const express = require('express');
const router = express.Router();
const { getUserTransactions } = require('../controllers/transactionController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.get('/:user_id', verifyToken, getUserTransactions);

module.exports = router;
