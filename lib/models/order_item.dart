import 'book.dart';

class OrderItem {
  final String orderItemID;
  final String orderID;
  final String bookID;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.orderItemID,
    required this.orderID,
    required this.bookID,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'OrderItemID': orderItemID,
      'OrderID': orderID,
      'BookID': bookID,
      'Quantity': quantity,
      'UnitPrice': unitPrice,
      'Subtotal': subtotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderItemID: map['OrderItemID'],
      orderID: map['OrderID'],
      bookID: map['BookID'],
      quantity: map['Quantity'],
      unitPrice: map['UnitPrice'],
      subtotal: map['Subtotal'],
    );
  }
}

class OrderItemWithBook {
  final OrderItem orderItem;
  final Book book;

  OrderItemWithBook({
    required this.orderItem,
    required this.book,
  });
}
