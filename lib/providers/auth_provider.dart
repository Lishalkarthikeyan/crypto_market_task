import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider(this._service);

  AppUser? _user;
  bool _ready = false;
  bool _busy = false;
  String? _error;

  AppUser? get user => _user;
  bool get ready => _ready;
  bool get busy => _busy;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<void> restore() async {
    _user = await _service.restoreSession();
    _ready = true;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<bool> signUp(String name, String email, String password) {
    return _run(
      () => _service.signUp(name: name, email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      _user = await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
