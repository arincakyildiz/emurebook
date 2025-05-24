const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes
router.get('/:id', userController.getUser);

// Protected routes
router.use(authMiddleware.protect);
router.get('/favorites/books', userController.getFavoriteBooks);
router.post('/upload-avatar', userController.uploadAvatar);

// Admin routes
router.use(authMiddleware.restrictTo('admin'));
router.get('/', userController.getAllUsers);
router.delete('/:id', userController.deleteUser);

module.exports = router; 