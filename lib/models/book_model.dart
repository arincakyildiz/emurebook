class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final String condition;
  final double price;
  final String category;
  final String exchangeType;
  final String? department;
  final String? courseCode;
  final Map<String, dynamic> owner;
  final String? isbn;
  final String language;
  final String? publisher;
  final int? publishedYear;
  final bool availability;
  final DateTime createdAt;
  final List<dynamic>? ratings;
  final double averageRating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    required this.condition,
    required this.price,
    required this.category,
    required this.exchangeType,
    this.department,
    this.courseCode,
    required this.owner,
    this.isbn,
    required this.language,
    this.publisher,
    this.publishedYear,
    required this.availability,
    required this.createdAt,
    this.ratings,
    this.averageRating = 0.0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      condition: json['condition'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      category: json['category'],
      exchangeType: json['exchangeType'],
      department: json['department'],
      courseCode: json['courseCode'],
      owner: json['owner'],
      isbn: json['isbn'],
      language: json['language'] ?? 'English',
      publisher: json['publisher'],
      publishedYear: json['publishedYear'],
      availability: json['availability'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      ratings: json['ratings'],
      averageRating: json['averageRating'] != null
          ? double.parse(json['averageRating'].toString())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'condition': condition,
      'price': price,
      'category': category,
      'exchangeType': exchangeType,
      'department': department,
      'courseCode': courseCode,
      'owner': owner,
      'isbn': isbn,
      'language': language,
      'publisher': publisher,
      'publishedYear': publishedYear,
      'availability': availability,
      'createdAt': createdAt.toIso8601String(),
      'ratings': ratings,
      'averageRating': averageRating,
    };
  }
}
