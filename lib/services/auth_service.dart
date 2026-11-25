import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String _salt = 'coinscope.v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _hash(String email, String password) {
    final bytes = utf8.encode('$_salt:$email:$password');
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, AppUser>> _readUsers(SharedPreferences prefs) async {
    final raw = prefs.getString(StorageKeys.users);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) =>
          MapEntry(key, AppUser.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<void> _writeUsers(
    SharedPreferences prefs,
    Map<String, AppUser> users,
  ) {
    final encoded = users.map((key, value) => MapEntry(key, value.toJson()));
    return prefs.setString(StorageKeys.users, jsonEncode(encoded));
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    final users = await _readUsers(prefs);
    final key = email.trim().toLowerCase();

    if (users.containsKey(key)) {
      throw const AuthException('An account with this email already exists');
    }

    final user = AppUser(
      name: name.trim(),
      email: key,
      passwordHash: _hash(key, password),
      createdAt: DateTime.now(),
    );

    users[key] = user;
    await _writeUsers(prefs, users);
    await prefs.setString(StorageKeys.session, key);
    return user;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    final users = await _readUsers(prefs);
    final key = email.trim().toLowerCase();
    final user = users[key];

    if (user == null || user.passwordHash != _hash(key, password)) {
      throw const AuthException('Incorrect email or password');
    }

    await prefs.setString(StorageKeys.session, key);
    return user;
  }

  Future<AppUser?> restoreSession() async {
    final prefs = await _prefs;
    final key = prefs.getString(StorageKeys.session);
    if (key == null) return null;
    final users = await _readUsers(prefs);
    return users[key];
  }

  Future<void> signOut() async {
    final prefs = await _prefs;
    await prefs.remove(StorageKeys.session);
  }
}
