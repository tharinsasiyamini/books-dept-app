import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Static data for Harry Potter search results
    final List<Book> staticHarryPotterBooks = [
      Book(
        bookID: 'B05',
        title: 'Harry Potter and the Philosopher\'s Stone',
        author: 'J.K. Rowling',
        price: 2400.00,
        description: 'Buy now Harry Potter and the Philosopher’s Stone from BooksDept Shop, Sri Lanka’s Number 1 Book Shop. J.K. Rowling’s beloved classic introduces readers to the magical world of Hogwarts, where young Harry Potter discovers his wizarding heritage, makes lifelong friends and faces thrilling adventures. Filled with wonder, imagination and unforgettable characters, Harry Potter and the Philosopher’s Stone is perfect for children, teens, and adults who love fantasy and magical storytelling. This timeless tale sparks curiosity, courage, and the joy of reading for all ages.',
        language: 'English',
      ),
      Book(
        bookID: 'B06',
        title: 'Harry Potter and the Chamber of Secrets',
        author: 'J.K. Rowling',
        price: 2400.00,
        language: 'English'
      ),
      Book(
        bookID: 'B07',
        title: 'Harry Potter and the Goblet of Fire',
        author: 'J.K. Rowling',
        price: 2400.00,
        language: 'English'
      ),
      Book(
        bookID: 'B08',
        title: 'Harry Potter and the Prisoner of Azkaban',
        author: 'J.K. Rowling',
        price: 2400.00,
        language: 'English'
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Figma background color
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100, left: 19, right: 19, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heart icon row from Figma Search Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB8E5), // Pink circle
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  query,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Static Results Grid
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: staticHarryPotterBooks.length,
                  itemBuilder: (context, index) {
                    return BookCard(book: staticHarryPotterBooks[index]);
                  },
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Bar with Search icon selected
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(selectedIndex: 1),
          ),
        ],
      ),
    );
  }
}
