import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/cart_item.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../state/auth_state.dart';
import 'customer_home_page.dart';
import 'payment_selection_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItemWithBook> cartItems;
  final double subTotal;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subTotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Wicky K Akash');
  final TextEditingController _addressController = TextEditingController(text: 'No.447/52, Cinnoman Lane,\nRosmed Place,Colombo 7');
  final TextEditingController _phoneController = TextEditingController(text: '+94 074 221 4587');
  
  DateTime? _selectedDate;
  
  final double deliveryFee = 500.00;
  final double discount = 150.00;
  
  double get orderTotal => widget.subTotal + deliveryFee - discount;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Choose a delivery date';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background like Figma
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row (Back, Checkout, Favorite)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB8E5), // Pink circle
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      
                      // Checkout Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: primaryColor),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      // Favorite Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB8E5), // Pink circle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                
                // Book Images & Billing Details Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      // Stack for overlapping book images
                      SizedBox(
                        width: 140,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: _buildBookStack(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Billing Details Button
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black54),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Billing Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Schedule Date Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.black),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              const Text(
                                'Schedule',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Billing Information Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      _buildTextFieldRow(
                        context,
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFieldRow(
                        context,
                        icon: Icons.location_on_outlined,
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFieldRow(
                        context,
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Order Summary Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryColor),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Order Summary Header
                        const Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.black),
                            SizedBox(width: 12),
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Summary Rows
                        _buildSummaryRow('Sub Total', 'LKR ${widget.subTotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Delivery Fees', 'LKR ${deliveryFee.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Discount', 'LKR (${discount.toStringAsFixed(2)})'),
                        
                        const SizedBox(height: 24),
                        const Divider(color: Colors.black12, thickness: 1),
                        const SizedBox(height: 24),
                        
                        // Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'LKR ${orderTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Order Now Button
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select a delivery date first."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                // Navigate to Payment Selection Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentSelectionPage(
                                      userId: AuthState.currentUser!.userID,
                                      cartId: 'C_${AuthState.currentUser!.userID}',
                                      deliveryDate: _selectedDate!.toIso8601String(),
                                      customerName: _nameController.text,
                                      deliveryAddress: _addressController.text,
                                      phoneNumber: _phoneController.text,
                                      deliveryFee: deliveryFee,
                                      discount: discount,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB8E5), // Pink button
                                foregroundColor: Colors.black, // Black text
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: primaryColor), // Purple border
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Order Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(selectedIndex: -1), // No icon selected on Checkout page
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookStack() {
    if (widget.cartItems.isEmpty) return [];

    List<Widget> stackWidgets = [];
    int limit = math.min(3, widget.cartItems.length); // Show up to 3 books

    for (int i = 0; i < limit; i++) {
      // Figma shows the first book slightly tilted left, the second straight
      double angle = 0.0;
      double leftOffset = i * 30.0; // Offset each book slightly to the right
      
      if (i == 0) {
        angle = -0.15; // Rotate slightly left
      } else if (i == 1) {
        angle = 0.1; // Rotate slightly right
      }

      stackWidgets.add(
        Positioned(
          left: leftOffset,
          top: i == 0 ? 20 : 0, // Drop the first book down slightly to match Figma
          child: Transform.rotate(
            angle: angle,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: widget.cartItems[i].book.buildImage(
                width: 90,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }
    
    // Reverse so the first item is on bottom of stack visually? 
    // Actually Figma shows the right-most (second) book on TOP of the first book.
    // In Flutter Stack, later widgets are drawn on top, so this is correct.
    return stackWidgets;
  }

  Widget _buildTextFieldRow(BuildContext context, {required IconData icon, required TextEditingController controller, int maxLines = 1, Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: maxLines > 1 ? 12.0 : 8.0),
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(maxLines > 1 ? 20 : 30),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
