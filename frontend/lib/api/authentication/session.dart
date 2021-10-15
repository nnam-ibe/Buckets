import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';

class UserSession extends ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  void setUser({required User user, required String token}) {
    _token = token;
    _user = user;
    notifyListeners();
  }

  void unsetUser() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
