import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/cart_item.dart';
import '../services/database_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../state/auth_state.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemWithBook> _cartItems = [];
  double _subtotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (!AuthState.isLoggedIn.value || AuthState.currentUser == null) return;
    final cartId = 'C_${AuthState.currentUser!.userID}';
    final items = await DatabaseHelper.instance.getCartItems(cartId);
    final total = await DatabaseHelper.instance.calculateCartTotal(cartId);
    setState(() {
      _cartItems = items;
      _subtotal = total;
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(String cartItemId, int newQty) async {
    await DatabaseHelper.instance.updateCartItemQuantity(cartItemId, newQty);
    _loadCart();
  }

  Future<void> _removeItem(String cartItemId) async {
    await DatabaseHelper.instance.removeFromCart(cartItemId);
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background like Figma
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Favorite Icon (Top Right)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB8E5), // Pink circle
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Cart Items
                      if (_cartItems.isEmpty)
                        const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 16)))
                      else
                        ..._cartItems.map((itemWithBook) => _buildCartItem(itemWithBook)).toList(),
                        
                      if (_cartItems.isNotEmpty) ...[
                        // Continue Shopping Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: primaryColor), // Assuming purple outline based on reference theme
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              '+ Continue Shopping',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Sub Total Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sub Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'LKR ${_subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Proceed to Checkout Button
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              if (_cartItems.isEmpty) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    cartItems: _cartItems,
                                    subTotal: _subtotal,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(selectedIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemWithBook itemWithBook) {
    final book = itemWithBook.book;
    final cartItem = itemWithBook.cartItem;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image without border/card
          book.buildImage(
            width: 100,
            height: 140,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          
          // Book Details & Quantity Control
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'LKR ${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quantity Control Pill
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (cartItem.quantity > 1) {
                              _updateQuantity(cartItem.cartItemID, cartItem.quantity - 1);
                            } else {
                              _removeItem(cartItem.cartItemID);
                            }
                          },
                          child: const Icon(CupertinoIcons.delete, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            _updateQuantity(cartItem.cartItemID, cartItem.quantity + 1);
                          },
                          child: const Icon(CupertinoIcons.add, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

