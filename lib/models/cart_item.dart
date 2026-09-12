import 'book.dart';

class CartItem {
  final String cartItemID;
  final String cartID;
  final String bookID;
  final int quantity;

  CartItem({
    required this.cartItemID,
    required this.cartID,
    required this.bookID,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'CartItemID': cartItemID,
      'CartID': cartID,
      'BookID': bookID,
      'Quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartItemID: map['CartItemID'] as String,
      cartID: map['CartID'] as String,
      bookID: map['BookID'] as String,
      quantity: map['Quantity'] as int,
    );
  }
}

// Helper class to easily display cart items with their book details in the UI
class CartItemWithBook {
  final CartItem cartItem;
  final Book book;

  CartItemWithBook({
    required this.cartItem,
    required this.book,
  });
}
