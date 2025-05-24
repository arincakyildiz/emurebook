const User = require('../models/user.model');
const Book = require('../models/book.model');
// Multer would be used for file uploads in a real app

// Get all users (admin only)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find();
    
    res.status(200).json({
      status: 'success',
      results: users.length,
      data: {
        users
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Get a single user
exports.getUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'No user found with that ID'
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        user
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Delete a user (admin only)
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'No user found with that ID'
      });
    }

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

// Get user's favorite books
exports.getFavoriteBooks = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate({
      path: 'favoriteBooks',
      populate: {
        path: 'owner',
        select: 'name avatar'
      }
    });

    res.status(200).json({
      status: 'success',
      results: user.favoriteBooks.length,
      data: {
        favoriteBooks: user.favoriteBooks
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Upload user avatar - simplified version
exports.uploadAvatar = async (req, res) => {
  try {
    // In a real app, this would use multer for file uploads
    // For now, we'll just update the avatar field with a URL

    const avatarUrl = req.body.avatarUrl;
    
    if (!avatarUrl) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide avatarUrl'
      });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { avatar: avatarUrl },
      { new: true }
    );

    res.status(200).json({
      status: 'success',
      data: {
        user
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
}; 