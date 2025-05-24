const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const User = require('../models/user.model');
const Book = require('../models/book.model');
const Message = require('../models/message.model');

// Load environment variables
dotenv.config();

// Sample users data
const users = [
  {
    name: 'Admin User',
    email: 'admin@example.com',
    password: 'password123',
    department: 'Computer Engineering',
    studentId: 'ADMIN001',
    phone: '555-123-4567',
    role: 'admin',
  },
  {
    name: 'Ahmet Yılmaz',
    email: 'ahmet@example.com',
    password: 'password123',
    department: 'Computer Engineering',
    studentId: 'CE1234567',
    phone: '555-234-5678',
  },
  {
    name: 'Ayşe Demir',
    email: 'ayse@example.com',
    password: 'password123',
    department: 'Electrical Engineering',
    studentId: 'EE7654321',
    phone: '555-345-6789',
  },
  {
    name: 'Mehmet Kaya',
    email: 'mehmet@example.com',
    password: 'password123',
    department: 'Civil Engineering',
    studentId: 'CE9876543',
    phone: '555-456-7890',
  },
];

// Sample books data - will be populated with user IDs
const books = [
  {
    title: 'Introduction to Algorithms',
    author: 'Thomas H. Cormen',
    description: 'A comprehensive introduction to the modern study of computer algorithms.',
    imageUrl: 'algorithms.jpg',
    condition: 'Good',
    price: 250,
    category: 'Computer Science',
    exchangeType: 'Sell',
    department: 'Computer Engineering',
    courseCode: 'CMPE 321',
    isbn: '978-0262033848',
    language: 'English',
    publisher: 'MIT Press',
    publishedYear: 2009,
  },
  {
    title: 'Calculus: Early Transcendentals',
    author: 'James Stewart',
    description: 'This book is for students taking calculus courses who want to learn the basic concepts of calculus and develop problem solving skills.',
    imageUrl: 'calculus.jpg',
    condition: 'Like New',
    price: 300,
    category: 'Mathematics',
    exchangeType: 'Exchange',
    department: 'Mathematics',
    courseCode: 'MATH 101',
    isbn: '978-1285741550',
    language: 'English',
    publisher: 'Cengage Learning',
    publishedYear: 2015,
  },
  {
    title: 'Operating System Concepts',
    author: 'Abraham Silberschatz',
    description: 'The tenth edition provides up-to-date materials and explanations of modern operating systems.',
    imageUrl: 'os.jpg',
    condition: 'Good',
    price: 200,
    category: 'Computer Science',
    exchangeType: 'Sell',
    department: 'Computer Engineering',
    courseCode: 'CMPE 322',
    isbn: '978-1118063330',
    language: 'English',
    publisher: 'Wiley',
    publishedYear: 2018,
  },
  {
    title: 'Computer Networks',
    author: 'Andrew S. Tanenbaum',
    description: 'This book is ideal for students of computer science and electrical engineering.',
    imageUrl: 'networking.jpg',
    condition: 'Fair',
    price: 150,
    category: 'Computer Science',
    exchangeType: 'Rent',
    department: 'Computer Engineering',
    courseCode: 'CMPE 476',
    isbn: '978-0132126953',
    language: 'English',
    publisher: 'Pearson',
    publishedYear: 2010,
  },
  {
    title: 'Engineering Mechanics: Statics',
    author: 'Russell C. Hibbeler',
    description: 'Engineering Mechanics: Statics excels in providing a clear and thorough presentation of the theory and application of engineering mechanics.',
    imageUrl: 'mechanics.jpg',
    condition: 'Good',
    price: 180,
    category: 'Engineering',
    exchangeType: 'Sell',
    department: 'Civil Engineering',
    courseCode: 'CE 201',
    isbn: '978-0133918922',
    language: 'English',
    publisher: 'Pearson',
    publishedYear: 2016,
  },
];

// Sample messages - will be populated with user IDs
const messages = [
  {
    content: 'Hello, is this book still available for sale?',
    isRead: true,
  },
  {
    content: 'Yes, it\'s still available. Are you interested?',
    isRead: true,
  },
  {
    content: 'How much are you selling it for?',
    isRead: false,
  },
];

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/emurebook')
  .then(async () => {
    console.log('Connected to MongoDB');
    
    try {
      // Clear previous data
      await User.deleteMany({});
      await Book.deleteMany({});
      await Message.deleteMany({});
      
      console.log('Previous data cleared');
      
      // Create users
      const createdUsers = [];
      for (const userData of users) {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(userData.password, salt);
        
        const user = await User.create({
          ...userData,
          password: hashedPassword,
        });
        
        createdUsers.push(user);
      }
      
      console.log(`${createdUsers.length} users created`);
      
      // Create books
      const createdBooks = [];
      for (let i = 0; i < books.length; i++) {
        const ownerIndex = (i % (createdUsers.length - 1)) + 1; // Skip admin user as owner
        
        const book = await Book.create({
          ...books[i],
          owner: createdUsers[ownerIndex]._id,
        });
        
        createdBooks.push(book);
      }
      
      console.log(`${createdBooks.length} books created`);
      
      // Create messages
      for (let i = 0; i < messages.length; i++) {
        const senderIndex = i % 2 === 0 ? 1 : 2; // Alternate between two users
        const receiverIndex = i % 2 === 0 ? 2 : 1;
        const bookIndex = i % createdBooks.length;
        
        await Message.create({
          ...messages[i],
          sender: createdUsers[senderIndex]._id,
          receiver: createdUsers[receiverIndex]._id,
          relatedBook: createdBooks[bookIndex]._id,
          createdAt: new Date(Date.now() - (messages.length - i) * 60000), // Stagger creation times
        });
      }
      
      console.log(`${messages.length} messages created`);
      
      console.log('Database seeded successfully!');
      process.exit(0);
    } catch (error) {
      console.error('Error seeding database:', error);
      process.exit(1);
    }
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  }); 