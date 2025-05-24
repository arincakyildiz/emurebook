# EmuReBook - Book Exchange Platform

EmuReBook is a mobile application developed to facilitate book exchange, sale, and rental transactions between university students.

## Features

- Create user account and login
- List, search, and filter books
- View book details
- Add books to favorites
- Message with book owners
- Rate and review books
- Edit user profile
- Multi-language support (English and Turkish)

## Technologies Used

**Frontend:**

- Flutter (Dart)
- Material Design UI components
- State management with StatefulWidget

**Backend:**

- Node.js with Express.js
- MongoDB database
- JWT authentication
- RESTful API architecture

## Installation

### Frontend (Flutter App)

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

### Backend (Node.js Server)

1. Navigate to the backend directory
2. Run `npm install` to install dependencies
3. Create `.env` file and configure database connection
4. Run `npm start` to start the server

## Project Structure

```
lib/
├── main.dart
├── models/
├── screens/
├── services/
├── widgets/
└── config/

backend/
├── src/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   └── utils/
├── package.json
└── README.md
```

## API Endpoints

### Authentication

- POST `/api/auth/register` - User registration
- POST `/api/auth/login` - User login
- POST `/api/auth/logout` - User logout

### Books

- GET `/api/books` - Get all books
- POST `/api/books` - Create new book listing
- GET `/api/books/:id` - Get book details
- PATCH `/api/books/:id` - Update book
- DELETE `/api/books/:id` - Delete book

### Messages

- GET `/api/messages/conversations` - Get user conversations
- POST `/api/messages` - Send message
- GET `/api/messages/conversations/:userId` - Get conversation with specific user

### Users

- GET `/api/users/profile` - Get user profile
- PATCH `/api/users/profile` - Update user profile
- PATCH `/api/users/password` - Update password

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
