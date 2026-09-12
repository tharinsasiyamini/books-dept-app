class Cart {
  final String cartID;
  final String userID;

  Cart({
    required this.cartID,
    required this.userID,
  });

  Map<String, dynamic> toMap() {
    return {
      'CartID': cartID,
      'UserID': userID,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      cartID: map['CartID'] as String,
      userID: map['UserID'] as String,
    );
  }
}
