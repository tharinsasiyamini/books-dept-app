import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/database_helper.dart';
import 'order_confirmed_page.dart';

class PaymentSelectionPage extends StatefulWidget {
  final String userId;
  final String cartId;
  final String deliveryDate;
  final String customerName;
  final String deliveryAddress;
  final String phoneNumber;
  final double deliveryFee;
  final double discount;

  const PaymentSelectionPage({
    super.key,
    required this.userId,
    required this.cartId,
    required this.deliveryDate,
    required this.customerName,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.deliveryFee,
    required this.discount,
  });

  @override
  State<PaymentSelectionPage> createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  // 'COD' or 'CARD'
  String _selectedMethod = 'COD';
  bool _isProcessing = false;

  Future<void> _processOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final orderId = await DatabaseHelper.instance.placeOrder(
        userId: widget.userId,
        cartId: widget.cartId,
        deliveryDate: widget.deliveryDate,
        customerName: widget.customerName,
        deliveryAddress: widget.deliveryAddress,
        phoneNumber: widget.phoneNumber,
        paymentMethod: _selectedMethod == 'COD' ? 'Cash on Delivery' : 'Credit / Debit Card',
        deliveryFee: widget.deliveryFee,
        discount: widget.discount,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmedPage(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
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
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Option 1: COD
                _buildPaymentOption(
                  id: 'COD',
                  icon: Icons.money,
                  title: 'Cash on Delivery',
                  subtitle: 'Cash handling fee applies',
                ),
                
                const SizedBox(height: 16),
                
                // Option 2: Card
                _buildPaymentOption(
                  id: 'CARD',
                  icon: Icons.credit_card, // Fallback icon for visa/mastercard
                  title: '********2280',
                  subtitle: 'Credit / Debit Card',
                  isCard: true,
                ),
                
                const SizedBox(height: 48),
                
                // Proceed Button
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB8E5), // Pink button
                        foregroundColor: Colors.black, // Black text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: primaryColor), // Purple border
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Proceed',
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
          
          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCard = false,
  }) {
    final isSelected = _selectedMethod == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        color: Colors.transparent, // to make the entire row clickable
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 40,
              decoration: isCard ? null : BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 28, color: isCard ? Colors.blue[800] : Colors.black),
            ),
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            // Radio Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
