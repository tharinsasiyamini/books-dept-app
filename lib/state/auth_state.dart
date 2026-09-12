import 'package:flutter/material.dart';
import '../models/user.dart';

// Simple global state for the prototype to track login status
class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static User? currentUser;

  static void login(User user) {
    currentUser = user;
    isLoggedIn.value = true;
  }

  static void logout() {
    currentUser = null;
    isLoggedIn.value = false;
  }
}
