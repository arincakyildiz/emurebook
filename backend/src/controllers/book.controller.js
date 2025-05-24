const Book = require('../models/book.model');
const User = require('../models/user.model');

// Get all books with filtering, sorting, pagination
exports.getAllBooks = async (req, res) => {
  try {
    // Build query
    const queryObj = { ...req.query };
    const excludedFields = ['page', 'sort', 'limit', 'fields'];
    excludedFields.forEach(el => delete queryObj[el]);

    // Advanced filtering
    let queryStr = JSON.stringify(queryObj);
    queryStr = queryStr.replace(/\b(gte|gt|lte|lt)\b/g, match => `$${match}`);

    let query = Book.find(JSON.parse(queryStr)).populate({
      path: 'owner',
      select: 'name avatar'
    });

    // Sorting
    if (req.query.sort) {
      const sortBy = req.query.sort.split(',').join(' ');
      query = query.sort(sortBy);
    } else {
      query = query.sort('-createdAt');
    }

    // Pagination
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    query = query.skip(skip).limit(limit);

    // Execute query
    const books = await query;

    res.status(200).json({
      status: 'success',
      results: books.length,
      data: {
        books
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Get a single book
exports.getBook = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id).populate({
      path: 'owner',
      select: 'name avatar department phone'
    });

    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'No book found with that ID'
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        book
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Create a new book
exports.createBook = async (req, res) => {
  try {
    // Add owner to req.body
    req.body.owner = req.user.id;

    const newBook = await Book.create(req.body);

    res.status(201).json({
      status: 'success',
      data: {
        book: newBook
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Update a book
exports.updateBook = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'No book found with that ID'
      });
    }

    // Check if user is book owner
    if (book.owner.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        status: 'fail',
        message: 'You are not allowed to update this book'
      });
    }

    const updatedBook = await Book.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      status: 'success',
      data: {
        book: updatedBook
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Delete a book
exports.deleteBook = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'No book found with that ID'
      });
    }

    // Check if user is book owner
    if (book.owner.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        status: 'fail',
        message: 'You are not allowed to delete this book'
      });
    }

    await Book.findByIdAndDelete(req.params.id);

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

// Get books by user ID
exports.getUserBooks = async (req, res) => {
  try {
    const books = await Book.find({ owner: req.params.userId }).populate({
      path: 'owner',
      select: 'name avatar'
    });

    res.status(200).json({
      status: 'success',
      results: books.length,
      data: {
        books
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Search books
exports.searchBooks = async (req, res) => {
  try {
    const searchTerm = req.query.q;
    
    if (!searchTerm) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide a search term'
      });
    }

    const books = await Book.find(
      { $text: { $search: searchTerm } },
      { score: { $meta: 'textScore' } }
    )
      .sort({ score: { $meta: 'textScore' } })
      .populate({
        path: 'owner',
        select: 'name avatar'
      });

    res.status(200).json({
      status: 'success',
      results: books.length,
      data: {
        books
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Get book categories
exports.getCategories = async (req, res) => {
  try {
    const categories = await Book.distinct('category');
    
    res.status(200).json({
      status: 'success',
      data: {
        categories
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Rate a book
exports.rateBook = async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        status: 'fail',
        message: 'Please provide a rating between 1 and 5'
      });
    }

    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'No book found with that ID'
      });
    }

    // Check if user has already rated this book
    const existingRatingIndex = book.ratings.findIndex(
      r => r.user.toString() === req.user.id
    );

    if (existingRatingIndex > -1) {
      // Update existing rating
      book.ratings[existingRatingIndex].rating = rating;
      book.ratings[existingRatingIndex].review = review;
    } else {
      // Add new rating
      book.ratings.push({
        user: req.user.id,
        rating,
        review
      });
    }

    await book.save();

    res.status(200).json({
      status: 'success',
      data: {
        book
      }
    });
  } catch (error) {
    res.status(400).json({
      status: 'fail',
      message: error.message
    });
  }
};

// Toggle favorite book
exports.toggleFavorite = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'No book found with that ID'
      });
    }

    const user = await User.findById(req.user.id);
    
    // Check if book is already in favorites
    const favoriteIndex = user.favoriteBooks.indexOf(book._id);
    
    if (favoriteIndex > -1) {
      // Remove from favorites
      user.favoriteBooks.splice(favoriteIndex, 1);
    } else {
      // Add to favorites
      user.favoriteBooks.push(book._id);
    }

    await user.save({ validateBeforeSave: false });

    res.status(200).json({
      status: 'success',
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