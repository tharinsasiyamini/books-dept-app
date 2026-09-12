class User {
  final String userID;
  final String name;
  final String email;
  final String password;
  final String role;

  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'Name': name,
      'Email': email,
      'Password': password,
      'Role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['UserID'] as String,
      name: map['Name'] as String,
      email: map['Email'] as String,
      password: map['Password'] as String,
      role: map['Role'] as String,
    );
  }
}
