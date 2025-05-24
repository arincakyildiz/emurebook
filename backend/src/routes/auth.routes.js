const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password/:token', authController.resetPassword);

// Protected routes
router.use(authMiddleware.protect);
router.post('/logout', authController.logout);
router.get('/me', authController.getMe);
router.patch('/update-password', authController.updatePassword);
router.patch('/update-me', authController.updateMe);

module.exports = router; 