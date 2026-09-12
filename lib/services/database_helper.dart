import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/notification.dart';
import 'dart:math' as math;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  static bool _tablesEnsured = false;

  Future<Database> get database async {
    if (_database != null) {
      if (!_tablesEnsured) {
        await _ensureTablesExist(_database!);
        _tablesEnsured = true;
      }
      return _database!;
    }

    _database = await _initDB('booksdept_v3.db');
    // Bulletproof fallback to ensure tables exist
    await _ensureTablesExist(_database!);
    _tablesEnsured = true;
    return _database!;
  }

  Future<void> _ensureTablesExist(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS CustomerOrder (
  OrderID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL,
  OrderDate TEXT NOT NULL,
  DeliveryDate TEXT NOT NULL,
  CustomerName TEXT NOT NULL,
  DeliveryAddress TEXT NOT NULL,
  PhoneNumber TEXT NOT NULL,
  PaymentMethod TEXT NOT NULL,
  SubTotal REAL NOT NULL,
  DeliveryFee REAL NOT NULL,
  Discount REAL NOT NULL,
  OrderTotal REAL NOT NULL,
  OrderStatus TEXT NOT NULL,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS OrderItem (
  OrderItemID TEXT PRIMARY KEY,
  OrderID TEXT NOT NULL,
  BookID TEXT NOT NULL,
  Quantity INTEGER NOT NULL CHECK (Quantity > 0),
  UnitPrice REAL NOT NULL,
  Subtotal REAL NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
)
''');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE CustomerOrder (
  OrderID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL,
  OrderDate TEXT NOT NULL,
  DeliveryDate TEXT NOT NULL,
  CustomerName TEXT NOT NULL,
  DeliveryAddress TEXT NOT NULL,
  PhoneNumber TEXT NOT NULL,
  PaymentMethod TEXT NOT NULL,
  SubTotal REAL NOT NULL,
  DeliveryFee REAL NOT NULL,
  Discount REAL NOT NULL,
  OrderTotal REAL NOT NULL,
  OrderStatus TEXT NOT NULL,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');

      await db.execute('''
CREATE TABLE OrderItem (
  OrderItemID TEXT PRIMARY KEY,
  OrderID TEXT NOT NULL,
  BookID TEXT NOT NULL,
  Quantity INTEGER NOT NULL CHECK (Quantity > 0),
  UnitPrice REAL NOT NULL,
  Subtotal REAL NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
)
''');
    }

    if (oldVersion < 3) {
      await db.execute('''
ALTER TABLE Book ADD COLUMN Stock INTEGER NOT NULL DEFAULT 20;
''');
      await db.execute('''
CREATE TABLE Notification (
  NotificationID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL,
  Message TEXT NOT NULL,
  Date TEXT NOT NULL,
  IsRead INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE Book (
  BookID TEXT PRIMARY KEY,
  Title TEXT NOT NULL,
  Author TEXT,
  Price REAL NOT NULL,
  ImageURL TEXT,
  Description TEXT,
  Language TEXT,
  Stock INTEGER NOT NULL DEFAULT 20
)
''');

    await db.execute('''
CREATE TABLE User (
  UserID TEXT PRIMARY KEY,
  Name TEXT NOT NULL,
  Email TEXT NOT NULL UNIQUE,
  Password TEXT NOT NULL,
  Role TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE Cart (
  CartID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL UNIQUE,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE CartItem (
  CartItemID TEXT PRIMARY KEY,
  CartID TEXT NOT NULL,
  BookID TEXT NOT NULL,
  Quantity INTEGER NOT NULL CHECK (Quantity > 0),
  FOREIGN KEY (CartID) REFERENCES Cart(CartID) ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE CustomerOrder (
  OrderID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL,
  OrderDate TEXT NOT NULL,
  DeliveryDate TEXT NOT NULL,
  CustomerName TEXT NOT NULL,
  DeliveryAddress TEXT NOT NULL,
  PhoneNumber TEXT NOT NULL,
  PaymentMethod TEXT NOT NULL,
  SubTotal REAL NOT NULL,
  DeliveryFee REAL NOT NULL,
  Discount REAL NOT NULL,
  OrderTotal REAL NOT NULL,
  OrderStatus TEXT NOT NULL,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE OrderItem (
  OrderItemID TEXT PRIMARY KEY,
  OrderID TEXT NOT NULL,
  BookID TEXT NOT NULL,
  Quantity INTEGER NOT NULL CHECK (Quantity > 0),
  UnitPrice REAL NOT NULL,
  Subtotal REAL NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES CustomerOrder(OrderID) ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE Notification (
  NotificationID TEXT PRIMARY KEY,
  UserID TEXT NOT NULL,
  Message TEXT NOT NULL,
  Date TEXT NOT NULL,
  IsRead INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
)
''');

    // Insert initial books
    final initialBooks = [
      {
        'BookID': 'B01',
        'Title': 'Charlie and the Chocolate Factory',
        'Author': 'Roald Dahl',
        'Price': 1500.00,
        'Stock': 20,
      },
      {
        'BookID': 'B02',
        'Title': 'Madol Duwa',
        'Author': 'Martin Wickramasinghe',
        'Price': 2000.00,
        'Stock': 20,
      },
      {
        'BookID': 'B03',
        'Title': 'Hath Pana',
        'Author': null,
        'Price': 1900.00,
        'Stock': 20,
      },
      {
        'BookID': 'B04',
        'Title': 'Twilight New Moon',
        'Author': 'Stephenie Meyer',
        'Price': 2200.00,
        'Stock': 20,
      },
      {
        'BookID': 'B05',
        'Title': 'Harry Potter and the Philosopher\'s Stone',
        'Author': 'J.K. Rowling',
        'Price': 2400.00,
        'Description':
            'Buy now Harry Potter and the Philosopher’s Stone from BooksDept Shop, Sri Lanka’s Number 1 Book Shop. J.K. Rowling’s beloved classic introduces readers to the magical world of Hogwarts, where young Harry Potter discovers his wizarding heritage, makes lifelong friends and faces thrilling adventures. Filled with wonder, imagination and unforgettable characters, Harry Potter and the Philosopher’s Stone is perfect for children, teens, and adults who love fantasy and magical storytelling. This timeless tale sparks curiosity, courage, and the joy of reading for all ages.',
        'Language': 'English',
        'Stock': 20,
      },
      {
        'BookID': 'B06',
        'Title': 'Harry Potter and the Chamber of Secrets',
        'Author': 'J.K. Rowling',
        'Price': 2400.00,
        'Stock': 3, // Simulate low stock
      },
      {
        'BookID': 'B07',
        'Title': 'Harry Potter and the Goblet of Fire',
        'Author': 'J.K. Rowling',
        'Price': 2400.00,
        'Stock': 20,
      },
      {
        'BookID': 'B08',
        'Title': 'Harry Potter and the Prisoner of Azkaban',
        'Author': 'J.K. Rowling',
        'Price': 2400.00,
        'Stock': 20,
      }
    ];

    for (var book in initialBooks) {
      await db.insert('Book', book);
    }

    // Insert sample user, cart, and cart items
    final user = User(
      userID: 'U01',
      name: 'Wicky',
      email: 'wicky@example.com',
      password: 'password123',
      role: 'Customer',
    );
    await db.insert('User', user.toMap());

    final cart = Cart(cartID: 'C01', userID: 'U01');
    await db.insert('Cart', cart.toMap());

    final cartItem1 = CartItem(
      cartItemID: 'CI01',
      cartID: 'C01',
      bookID: 'B05',
      quantity: 1,
    );
    final cartItem2 = CartItem(
      cartItemID: 'CI02',
      cartID: 'C01',
      bookID: 'B02',
      quantity: 1,
    );
    await db.insert('CartItem', cartItem1.toMap());
    await db.insert('CartItem', cartItem2.toMap());
  }

  // FORCE RESET FUNCTION TO FIX EMPTY DB ISSUES
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'booksdept_v3.db');
    
    // Close existing connection if any
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    
    // Delete and nullify
    await deleteDatabase(path);
    _database = null;
    _tablesEnsured = false;
    
    // Re-initialize
    await database;
  }

  Future<List<Book>> getHomeBooks() async {
    final db = await instance.database;
    final maps = await db.query('Book');
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'Book',
      where: 'Title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<Book?> getBookById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'Book',
      where: 'BookID = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // User Methods
  Future<void> createUser(User user) async {
    final db = await instance.database;
    await db.insert('User', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'User',
      where: 'Email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final maps = await db.query('User', orderBy: 'Role ASC, Name ASC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<User?> getUserById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'User',
      where: 'UserID = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Cart Methods
  Future<void> createCart(Cart cart) async {
    final db = await instance.database;
    await db.insert('Cart', cart.toMap());
  }

  Future<Cart?> getCartByUserId(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'Cart',
      where: 'UserID = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) return Cart.fromMap(maps.first);
    return null;
  }

  // Cart Item Methods
  Future<void> addToCart(String cartId, String bookId, int quantity) async {
    final db = await instance.database;
    
    // Check if it already exists
    final existing = await db.query(
      'CartItem',
      where: 'CartID = ? AND BookID = ?',
      whereArgs: [cartId, bookId],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      final currentQty = existing.first['Quantity'] as int;
      final cartItemId = existing.first['CartItemID'] as String;
      
      await updateCartItemQuantity(cartItemId, currentQty + quantity);
    } else {
      // Insert new
      final cartItemId = 'CI_${DateTime.now().millisecondsSinceEpoch}';
      final item = CartItem(
        cartItemID: cartItemId,
        cartID: cartId,
        bookID: bookId,
        quantity: quantity,
      );
      await db.insert('CartItem', item.toMap());
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    final db = await instance.database;
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await db.update(
        'CartItem',
        {'Quantity': newQuantity},
        where: 'CartItemID = ?',
        whereArgs: [cartItemId],
      );
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final db = await instance.database;
    await db.delete(
      'CartItem',
      where: 'CartItemID = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<List<CartItemWithBook>> getCartItems(String cartId) async {
    final db = await instance.database;
    
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        ci.CartItemID, ci.CartID, ci.BookID, ci.Quantity,
        b.Title, b.Author, b.Price, b.ImageURL, b.Description, b.Language
      FROM CartItem ci
      INNER JOIN Book b ON ci.BookID = b.BookID
      WHERE ci.CartID = ?
    ''', [cartId]);

    return results.map((map) {
      final cartItem = CartItem(
        cartItemID: map['CartItemID'],
        cartID: map['CartID'],
        bookID: map['BookID'],
        quantity: map['Quantity'],
      );
      final book = Book(
        bookID: map['BookID'],
        title: map['Title'],
        author: map['Author'],
        price: map['Price'],
        imageURL: map['ImageURL'],
        description: map['Description'],
        language: map['Language'],
      );
      return CartItemWithBook(cartItem: cartItem, book: book);
    }).toList();
  }

  Future<double> calculateCartTotal(String cartId) async {
    final db = await instance.database;
    
    final result = await db.rawQuery('''
      SELECT SUM(b.Price * ci.Quantity) as Total
      FROM CartItem ci
      INNER JOIN Book b ON ci.BookID = b.BookID
      WHERE ci.CartID = ?
    ''', [cartId]);
    
    if (result.isNotEmpty && result.first['Total'] != null) {
      return (result.first['Total'] as num).toDouble();
    }
    return 0.0;
  }

  // Order Methods
  Future<String> placeOrder({
    required String userId,
    required String cartId,
    required String deliveryDate,
    required String customerName,
    required String deliveryAddress,
    required String phoneNumber,
    required String paymentMethod,
    required double deliveryFee,
    required double discount,
  }) async {
    final db = await instance.database;
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';

    await db.transaction((txn) async {
      // 1. Get cart items
      final List<Map<String, dynamic>> cartItems = await txn.rawQuery('''
        SELECT ci.CartItemID, ci.BookID, ci.Quantity, b.Price
        FROM CartItem ci
        INNER JOIN Book b ON ci.BookID = b.BookID
        WHERE ci.CartID = ?
      ''', [cartId]);

      if (cartItems.isEmpty) {
        throw Exception("Cart is empty");
      }

      // 2. Calculate SubTotal
      double subTotal = 0.0;
      for (var item in cartItems) {
        final price = (item['Price'] as num).toDouble();
        final qty = item['Quantity'] as int;
        subTotal += (price * qty);
      }

      final double orderTotal = subTotal + deliveryFee - discount;

      // 3. Insert Order
      final order = Order(
        orderID: orderId,
        userID: userId,
        orderDate: DateTime.now().toIso8601String(),
        deliveryDate: deliveryDate,
        customerName: customerName,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        paymentMethod: paymentMethod,
        subTotal: subTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        orderTotal: orderTotal,
        orderStatus: 'Pending',
      );
      await txn.insert('CustomerOrder', order.toMap());

      // 4. Insert Order Items
      for (var item in cartItems) {
        final bookId = item['BookID'] as String;
        final qty = item['Quantity'] as int;
        final unitPrice = (item['Price'] as num).toDouble();
        final itemSubtotal = unitPrice * qty;

        final orderItem = OrderItem(
          orderItemID: 'OI_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}',
          orderID: orderId,
          bookID: bookId,
          quantity: qty,
          unitPrice: unitPrice,
          subtotal: itemSubtotal,
        );
        await txn.insert('OrderItem', orderItem.toMap());
      }

      // 5. Clear Cart Items
      await txn.delete(
        'CartItem',
        where: 'CartID = ?',
        whereArgs: [cartId],
      );
    });

    return orderId;
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final db = await instance.database;
    
    final orderMaps = await db.query(
      'CustomerOrder',
      where: 'OrderID = ?',
      whereArgs: [orderId],
    );

    if (orderMaps.isEmpty) {
      throw Exception('Order not found');
    }

    final order = Order.fromMap(orderMaps.first);

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        oi.OrderItemID, oi.OrderID, oi.BookID, oi.Quantity, oi.UnitPrice, oi.Subtotal,
        b.Title, b.Author, b.Price, b.ImageURL, b.Description, b.Language
      FROM OrderItem oi
      INNER JOIN Book b ON oi.BookID = b.BookID
      WHERE oi.OrderID = ?
    ''', [orderId]);

    final orderItems = results.map((map) {
      final orderItem = OrderItem(
        orderItemID: map['OrderItemID'],
        orderID: map['OrderID'],
        bookID: map['BookID'],
        quantity: map['Quantity'],
        unitPrice: map['UnitPrice'],
        subtotal: map['Subtotal'],
      );
      final book = Book(
        bookID: map['BookID'],
        title: map['Title'],
        author: map['Author'],
        price: map['Price'], // Note: Book price might have changed, but OrderItem keeps historical UnitPrice
        imageURL: map['ImageURL'],
        description: map['Description'],
        language: map['Language'],
      );
      return OrderItemWithBook(orderItem: orderItem, book: book);
    }).toList();

    return {
      'order': order,
      'items': orderItems,
    };
  }

  Future<int> getOrdersCountByStatus(String status) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM CustomerOrder WHERE OrderStatus = ?', [status]),
    );
    return count ?? 0;
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    final db = await instance.database;
    final orderMaps = await db.query(
      'CustomerOrder',
      where: 'OrderStatus = ?',
      whereArgs: [status],
      orderBy: 'OrderDate DESC',
    );

    return orderMaps.map((map) => Order.fromMap(map)).toList();
  }

  Future<void> updateBookStock(String bookID, int newStock) async {
    final db = await instance.database;
    await db.update(
      'Book',
      {'Stock': newStock},
      where: 'BookID = ?',
      whereArgs: [bookID],
    );
  }

  Future<void> updateOrderStatus(String orderID, String newStatus) async {
    final db = await instance.database;
    await db.update(
      'CustomerOrder',
      {'OrderStatus': newStatus},
      where: 'OrderID = ?',
      whereArgs: [orderID],
    );
  }

  Future<void> createNotification(AppNotification notification) async {
    final db = await instance.database;
    await db.insert('Notification', notification.toMap());
  }

  Future<List<AppNotification>> getNotificationsForUser(String userID) async {
    final db = await instance.database;
    final maps = await db.query(
      'Notification',
      where: 'UserID = ?',
      whereArgs: [userID],
      orderBy: 'Date DESC',
    );
    return maps.map((map) => AppNotification.fromMap(map)).toList();
  }

  Future<void> markNotificationsAsRead(String userID) async {
    final db = await instance.database;
    await db.update(
      'Notification',
      {'IsRead': 1},
      where: 'UserID = ? AND IsRead = 0',
      whereArgs: [userID],
    );
  }

  Future<void> clearNotifications(String userID) async {
    final db = await instance.database;
    await db.delete(
      'Notification',
      where: 'UserID = ?',
      whereArgs: [userID],
    );
  }

  Future<int> getLowStockBooksCount() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM Book WHERE Stock <= 5'),
    );
    return count ?? 0;
  }

  Future<void> createBook(Book book) async {
    final db = await instance.database;
    await db.insert('Book', book.toMap());
  }

  Future<void> deleteBook(String bookID) async {
    final db = await instance.database;
    await db.delete(
      'Book',
      where: 'BookID = ?',
      whereArgs: [bookID],
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await instance.database;
    final maps = await db.query('Book', orderBy: 'Title ASC');
    return maps.map((map) => Book.fromMap(map)).toList();
  }
}
