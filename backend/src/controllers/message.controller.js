const Message = require('../models/message.model');
const User = require('../models/user.model');

// Get all messages for current user
exports.getMyMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [
        { sender: req.user.id },
        { receiver: req.user.id }
      ]
    })
    .sort('-createdAt')
    .populate({
      path: 'sender',
      select: 'name avatar'
    })
    .populate({
      path: 'receiver',
      select: 'name avatar'
    })
    .populate({
      path: 'relatedBook',
      select: 'title imageUrl'
    });

    res.status(200).json({
      status: 'success',
      results: messages.length,
      data: {
        messages
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Get all conversations for current user
exports.getMyConversations = async (req, res) => {
  try {
    // Find all messages where current user is either sender or receiver
    const messages = await Message.find({
      $or: [
        { sender: req.user.id },
        { receiver: req.user.id }
      ]
    })
    .sort('-createdAt')
    .populate({
      path: 'sender',
      select: 'name avatar'
    })
    .populate({
      path: 'receiver',
      select: 'name avatar'
    });

    // Extract unique conversations
    const conversations = [];
    const conversationMap = new Map();

    messages.forEach(message => {
      // Determine the other person in the conversation
      const otherPerson = message.sender._id.toString() === req.user.id ? 
        message.receiver : message.sender;
      
      const conversationId = otherPerson._id.toString();
      
      if (!conversationMap.has(conversationId)) {
        conversationMap.set(conversationId, {
          user: otherPerson,
          lastMessage: message,
          unreadCount: message.receiver._id.toString() === req.user.id && !message.isRead ? 1 : 0
        });
      } else {
        // Update unread count
        if (message.receiver._id.toString() === req.user.id && !message.isRead) {
          conversationMap.get(conversationId).unreadCount += 1;
        }
      }
    });

    // Convert map to array
    conversationMap.forEach(conversation => {
      conversations.push(conversation);
    });

    // Sort by last message time
    conversations.sort((a, b) => 
      new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt)
    );

    res.status(200).json({
      status: 'success',
      results: conversations.length,
      data: {
        conversations
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Get conversation with specific user
exports.getConversationWithUser = async (req, res) => {
  try {
    const otherUserId = req.params.userId;
    
    // Check if other user exists
    const otherUser = await User.findById(otherUserId);
    if (!otherUser) {
      return res.status(404).json({
        status: 'fail',
        message: 'No user found with that ID'
      });
    }

    // Find messages between current user and other user
    const messages = await Message.find({
      $or: [
        { sender: req.user.id, receiver: otherUserId },
        { sender: otherUserId, receiver: req.user.id }
      ]
    })
    .sort('createdAt')
    .populate({
      path: 'relatedBook',
      select: 'title imageUrl'
    });

    // Mark all messages as read
    await Message.updateMany(
      { sender: otherUserId, receiver: req.user.id, isRead: false },
      { isRead: true }
    );

    res.status(200).json({
      status: 'success',
      data: {
        user: {
          _id: otherUser._id,
          name: otherUser.name,
          avatar: otherUser.avatar
        },
        messages
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Send a message
exports.sendMessage = async (req, res) => {
  try {
    const { receiver, content, relatedBook } = req.body;

    if (!receiver || !content) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide receiver and content'
      });
    }

    // Check if receiver exists
    const receiverUser = await User.findById(receiver);
    if (!receiverUser) {
      return res.status(404).json({
        status: 'fail',
        message: 'Receiver not found'
      });
    }

    // Create new message
    const newMessage = await Message.create({
      sender: req.user.id,
      receiver,
      content,
      relatedBook
    });

    await newMessage.populate([
      {
        path: 'sender',
        select: 'name avatar'
      },
      {
        path: 'receiver',
        select: 'name avatar'
      },
      {
        path: 'relatedBook',
        select: 'title imageUrl'
      }
    ]);

    res.status(201).json({
      status: 'success',
      data: {
        message: newMessage
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Mark message as read
exports.markAsRead = async (req, res) => {
  try {
    const message = await Message.findById(req.params.id);
    
    if (!message) {
      return res.status(404).json({
        status: 'fail',
        message: 'No message found with that ID'
      });
    }

    // Check if user is the receiver
    if (message.receiver.toString() !== req.user.id) {
      return res.status(403).json({
        status: 'fail',
        message: 'You can only mark messages sent to you as read'
      });
    }

    message.isRead = true;
    await message.save();

    res.status(200).json({
      status: 'success',
      data: {
        message
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Delete a message
exports.deleteMessage = async (req, res) => {
  try {
    const message = await Message.findById(req.params.id);
    
    if (!message) {
      return res.status(404).json({
        status: 'fail',
        message: 'No message found with that ID'
      });
    }

    // Check if user is the sender or receiver
    if (
      message.sender.toString() !== req.user.id && 
      message.receiver.toString() !== req.user.id
    ) {
      return res.status(403).json({
        status: 'fail',
        message: 'You can only delete messages you sent or received'
      });
    }

    await Message.findByIdAndDelete(req.params.id);

    res.status(204).json({
      status: 'success',
      data: null
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
}; 