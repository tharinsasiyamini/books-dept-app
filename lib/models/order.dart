class Order {
  final String orderID;
  final String userID;
  final String orderDate;
  final String deliveryDate;
  final String customerName;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;
  final double subTotal;
  final double deliveryFee;
  final double discount;
  final double orderTotal;
  final String orderStatus;

  Order({
    required this.orderID,
    required this.userID,
    required this.orderDate,
    required this.deliveryDate,
    required this.customerName,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.subTotal,
    required this.deliveryFee,
    required this.discount,
    required this.orderTotal,
    this.orderStatus = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'OrderID': orderID,
      'UserID': userID,
      'OrderDate': orderDate,
      'DeliveryDate': deliveryDate,
      'CustomerName': customerName,
      'DeliveryAddress': deliveryAddress,
      'PhoneNumber': phoneNumber,
      'PaymentMethod': paymentMethod,
      'SubTotal': subTotal,
      'DeliveryFee': deliveryFee,
      'Discount': discount,
      'OrderTotal': orderTotal,
      'OrderStatus': orderStatus,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderID: map['OrderID'],
      userID: map['UserID'],
      orderDate: map['OrderDate'],
      deliveryDate: map['DeliveryDate'],
      customerName: map['CustomerName'],
      deliveryAddress: map['DeliveryAddress'],
      phoneNumber: map['PhoneNumber'],
      paymentMethod: map['PaymentMethod'],
      subTotal: (map['SubTotal'] as num).toDouble(),
      deliveryFee: (map['DeliveryFee'] as num).toDouble(),
      discount: (map['Discount'] as num).toDouble(),
      orderTotal: (map['OrderTotal'] as num).toDouble(),
      orderStatus: map['OrderStatus'],
    );
  }
}
