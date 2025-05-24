const User = require('../models/user.model');
const jwt = require('jsonwebtoken');

// Generate JWT token
const signToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN
  });
};

// Send JWT token with response
const createSendToken = (user, statusCode, res) => {
  const token = signToken(user._id);
  
  // Remove password from output
  user.password = undefined;

  res.status(statusCode).json({
    status: 'success',
    token,
    data: {
      user
    }
  });
};

// Register new user
exports.register = async (req, res) => {
  try {
    const newUser = await User.create({
      name: req.body.name,
      email: req.body.email,
      password: req.body.password,
      department: req.body.department,
      studentId: req.body.studentId,
      phone: req.body.phone
    });

    createSendToken(newUser, 201, res);
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Login user
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if email and password exist
    if (!email || !password) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide email and password'
      });
    }

    // Check if user exists and password is correct
    const user = await User.findOne({ email }).select('+password');
    
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({
        status: 'fail',
        message: 'Incorrect email or password'
      });
    }

    // If everything is ok, send token to client
    createSendToken(user, 200, res);
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Logout user (client-side)
exports.logout = (req, res) => {
  res.status(200).json({ status: 'success' });
};

// Get current user
exports.getMe = (req, res) => {
  res.status(200).json({
    status: 'success',
    data: {
      user: req.user
    }
  });
};

// Update password
exports.updatePassword = async (req, res) => {
  try {
    // Get user from collection
    const user = await User.findById(req.user.id).select('+password');

    // Check if current password is correct
    if (!(await user.comparePassword(req.body.currentPassword))) {
      return res.status(401).json({
        status: 'fail',
        message: 'Your current password is incorrect'
      });
    }

    // If so, update password
    user.password = req.body.newPassword;
    await user.save();

    // Log user in, send JWT
    createSendToken(user, 200, res);
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Update user data
exports.updateMe = async (req, res) => {
  try {
    // Create error if user tries to update password
    if (req.body.password) {
      return res.status(400).json({
        status: 'fail',
        message: 'This route is not for password updates. Please use /update-password'
      });
    }

    // Filter out unwanted fields
    const filteredBody = {
      name: req.body.name,
      email: req.body.email,
      department: req.body.department,
      phone: req.body.phone
    };

    // Update user document
    const updatedUser = await User.findByIdAndUpdate(req.user.id, filteredBody, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      status: 'success',
      data: {
        user: updatedUser
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Forgot password - simplified version (would need email service in real app)
exports.forgotPassword = async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'There is no user with that email address'
      });
    }

    // In a real app, generate reset token and send email
    // For now, just return success message
    res.status(200).json({
      status: 'success',
      message: 'Token sent to email!'
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Reset password - simplified version
exports.resetPassword = async (req, res) => {
  try {
    // In a real app, find user by reset token
    // For now, just return error
    res.status(400).json({
      status: 'fail',
      message: 'This feature is not implemented yet'
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
}; 