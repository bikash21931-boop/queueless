const express = require('express');
const router = express.Router();
const { login, register, updateBudget } = require('../controllers/authController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/login', login);
router.post('/register', register);
router.post('/budget', verifyToken, updateBudget);

module.exports = router;
