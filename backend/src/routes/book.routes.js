const express = require('express');
const router = express.Router();
const bookController = require('../controllers/book.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes
router.get('/', bookController.getAllBooks);
router.get('/search', bookController.searchBooks);
router.get('/categories', bookController.getCategories);
router.get('/:id', bookController.getBook);
router.get('/user/:userId', bookController.getUserBooks);

// Protected routes
router.use(authMiddleware.protect);
router.post('/', bookController.createBook);
router.patch('/:id', bookController.updateBook);
router.delete('/:id', bookController.deleteBook);
router.post('/:id/rating', bookController.rateBook);
router.post('/:id/favorite', bookController.toggleFavorite);

module.exports = router; 