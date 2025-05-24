const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All message routes are protected
router.use(authMiddleware.protect);

router.get('/', messageController.getMyMessages);
router.get('/conversations', messageController.getMyConversations);
router.get('/conversation/:userId', messageController.getConversationWithUser);
router.post('/', messageController.sendMessage);
router.patch('/:id/read', messageController.markAsRead);
router.delete('/:id', messageController.deleteMessage);

module.exports = router; 