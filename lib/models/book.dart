class Book {
  final String bookID;
  final String title;
  final String? author;
  final double price;
  final String? imageURL;
  final String? description;
  final String? language;

  Book({
    required this.bookID,
    required this.title,
    this.author,
    required this.price,
    this.imageURL,
    this.description,
    this.language,
  });

  // Convert a Book into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'BookID': bookID,
      'Title': title,
      'Author': author,
      'Price': price,
      'ImageURL': imageURL,
      'Description': description,
      'Language': language,
    };
  }

  // Convert a Map into a Book.
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      bookID: map['BookID'] as String,
      title: map['Title'] as String,
      author: map['Author'] as String?,
      price: (map['Price'] as num).toDouble(),
      imageURL: map['ImageURL'] as String?,
      description: map['Description'] as String?,
      language: map['Language'] as String?,
    );
  }

  // Helper method to get the local image path based on BookID
  String get localImagePath {
    switch (bookID) {
      case 'B01':
        return 'assets/images/charlieAndTheChocolateFactory.png';
      case 'B02':
        return 'assets/images/madolDoova.png';
      case 'B03':
        return 'assets/images/hathPana.png';
      case 'B04':
        return 'assets/images/twilight.png';
      case 'B05':
        return 'assets/images/Harry Potter and the Philosopher\'s Stone.jpg';
      case 'B06':
        return 'assets/images/Harry Potter and the Chamber of Secrets.jpg';
      case 'B07':
        return 'assets/images/Harry Potter and the Goblet of Fire.jpeg';
      case 'B08':
        return 'assets/images/Harry Potter and the Prisoner of Azkaban.jpeg';
      default:
        // Return a default image or null path if we want to handle it
        return 'assets/images/charlieAndTheChocolateFactory.png'; // fallback
    }
  }
}
