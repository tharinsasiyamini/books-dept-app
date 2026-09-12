import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_details_page.dart';
import '../screens/login_page.dart';
import '../services/database_helper.dart';
import '../state/auth_state.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary), // #8c0d5d
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          // Book Cover Image - ONLY THIS IS TAPPABLE FOR DETAILS
          Expanded(
            flex: 3, // Take up roughly 3/4 of the card space
            child: InkWell(
              onTap: onTap ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(bookID: book.bookID),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                    child: Image.asset(
                      book.localImagePath,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Book Details
          Expanded(
            flex: 2, // Take up 2/4 of the card space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute text and price evenly
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'LKR ${book.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // Add to cart icon button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Clear previous
                            
                            if (!AuthState.isLoggedIn.value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Login to Purchase Books"),
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: 'LOGIN',
                                    textColor: Colors.pinkAccent,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final cartId = 'C_${AuthState.currentUser!.userID}';
                              await DatabaseHelper.instance.addToCart(cartId, book.bookID, 1);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Added ${book.title} to cart"),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to add: $e"),
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
