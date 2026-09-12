class AppNotification {
  final String notificationID;
  final String userID;
  final String message;
  final String date;
  final int isRead;

  AppNotification({
    required this.notificationID,
    required this.userID,
    required this.message,
    required this.date,
    this.isRead = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'NotificationID': notificationID,
      'UserID': userID,
      'Message': message,
      'Date': date,
      'IsRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      notificationID: map['NotificationID'] as String,
      userID: map['UserID'] as String,
      message: map['Message'] as String,
      date: map['Date'] as String,
      isRead: map['IsRead'] as int,
    );
  }
}
