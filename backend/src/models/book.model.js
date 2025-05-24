const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'A book must have a title'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  author: {
    type: String,
    required: [true, 'A book must have an author'],
    trim: true,
    maxlength: [50, 'Author name cannot exceed 50 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  imageUrl: {
    type: String,
    default: 'default-book.jpg'
  },
  condition: {
    type: String,
    enum: ['New', 'Like New', 'Good', 'Fair', 'Poor'],
    default: 'Good'
  },
  price: {
    type: Number,
    default: 0
  },
  category: {
    type: String,
    required: [true, 'A book must have a category'],
    trim: true
  },
  exchangeType: {
    type: String,
    enum: ['Sell', 'Exchange', 'Free', 'Rent'],
    default: 'Sell'
  },
  department: {
    type: String,
    trim: true
  },
  courseCode: {
    type: String,
    trim: true
  },
  owner: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: [true, 'A book must belong to an owner']
  },
  isbn: {
    type: String,
    trim: true
  },
  language: {
    type: String,
    default: 'English'
  },
  publisher: {
    type: String,
    trim: true
  },
  publishedYear: {
    type: Number
  },
  availability: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now()
  },
  ratings: [{
    user: {
      type: mongoose.Schema.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5
    },
    review: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Calculate average rating
bookSchema.virtual('averageRating').get(function() {
  if (this.ratings.length === 0) return 0;
  
  const sum = this.ratings.reduce((total, rating) => total + rating.rating, 0);
  return (sum / this.ratings.length).toFixed(1);
});

// Index for searching
bookSchema.index({ title: 'text', author: 'text', description: 'text' });

module.exports = mongoose.model('Book', bookSchema); 