const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: [true, 'A message must have a sender']
  },
  receiver: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: [true, 'A message must have a receiver']
  },
  content: {
    type: String,
    required: [true, 'Message content cannot be empty'],
    trim: true,
    maxlength: [1000, 'Message content cannot exceed 1000 characters']
  },
  relatedBook: {
    type: mongoose.Schema.ObjectId,
    ref: 'Book'
  },
  isRead: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create compound index for conversation querying
messageSchema.index({ sender: 1, receiver: 1 });

module.exports = mongoose.model('Message', messageSchema); 