import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'favorite_page.dart';
import 'search_results_page.dart';
import '../state/auth_state.dart';
import '../services/database_helper.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String _searchQuery = '';
  String _selectedCategory = 'BEST SELLERS';
  List<Book> _homeBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeBooks();
  }

  Future<void> _loadHomeBooks() async {
    try {
      var books = await DatabaseHelper.instance.getHomeBooks();
      
      // Auto-recover if database is missing initial books
      if (books.isEmpty) {
        await DatabaseHelper.instance.resetDatabase();
        books = await DatabaseHelper.instance.getHomeBooks();
      }
      
      if (mounted) {
        setState(() {
          _homeBooks = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading books: $e')),
        );
      }
    }
  }
  
  List<Book> get _filteredBooks {
    if (_searchQuery.isEmpty) return _homeBooks;
    return _homeBooks.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             (book.author?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // User Greeting Profile Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: AuthState.isLoggedIn,
                        builder: (context, isLoggedIn, child) {
                          if (!isLoggedIn) {
                            return const SizedBox.shrink(); // Hide if not logged in
                          }
                          return Row(
                            children: [
                              const CircleAvatar(
                                radius: 41, 
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/images/Profile image.png.png'), 
                              ),
                              const SizedBox(width: 16),
                              Text(
                                AuthState.isLoggedIn.value && AuthState.currentUser != null 
                                    ? 'Hello ${AuthState.currentUser!.name}' 
                                    : 'Hello Guest',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // Favorite Icon Circle
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FavoritePage()),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFB8E5), // Pink circle from Figma
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Container(
                    height: 48, // slightly taller for TextField
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultsPage(query: value.trim()),
                            ),
                          );
                        }
                      },
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.black, size: 28),
                        hintText: 'Search Book',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    children: [
                      _buildCategoryChip(context, 'BEST SELLERS', _selectedCategory == 'BEST SELLERS'),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'FEATURED', _selectedCategory == 'FEATURED'),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'FAVORITE', _selectedCategory == 'FAVORITE'),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'NEW ARRIVALS', _selectedCategory == 'NEW ARRIVALS'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Book Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65, // Increased to make the cards shorter and reduce gap
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            return BookCard(
                              book: _filteredBooks[index],
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("The Book Details are not yet Updated"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                if (!_isLoading && _filteredBooks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text("No books found matching your search."),
                    ),
                  )
              ],
            ),
          ),

          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
