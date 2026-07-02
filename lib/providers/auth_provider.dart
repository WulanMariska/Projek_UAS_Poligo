import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.register(email: email, password: password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
