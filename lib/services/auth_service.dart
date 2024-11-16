import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionBoxName = 'session';

  // Enkripsi password menggunakan SHA-256 dengan salt
  String _encryptPassword(String password) {
    final salt = "YOUR_SECURE_SALT_HERE"; // Ganti dengan salt yang aman
    final saltedPassword = password + salt;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register user baru
  Future<bool> register(String username, String password, String email) async {
    try {
      final box = await Hive.openBox<User>(userBoxName);

      // Cek apakah username atau email sudah ada
      if (box.values.any((user) =>
          user.username.toLowerCase() == username.toLowerCase() ||
          user.email.toLowerCase() == email.toLowerCase())) {
        return false;
      }

      // Encrypt password
      final encryptedPassword = _encryptPassword(password);

      // Simpan user baru
      final user = User(
        username: username,
        password: encryptedPassword,
        email: email,
        lastLogin: DateTime.now(),
      );

      await box.add(user);
      return true;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Login user
  Future<User?> login(String username, String password) async {
    try {
      final box = await Hive.openBox<User>(userBoxName);
      final sessionBox = await Hive.openBox(sessionBoxName);
      final encryptedPassword = _encryptPassword(password);

      final user = box.values.firstWhere(
        (user) =>
            user.username.toLowerCase() == username.toLowerCase() &&
            user.password == encryptedPassword,
        orElse: () => throw Exception('User not found'),
      );

      // Update last login
      user.lastLogin = DateTime.now();
      await user.save();

      // Save session
      await sessionBox.put('currentUser', user.key);

      return user;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    final sessionBox = await Hive.openBox(sessionBoxName);
    await sessionBox.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final sessionBox = await Hive.openBox(sessionBoxName);
    return sessionBox.containsKey('currentUser');
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final sessionBox = await Hive.openBox(sessionBoxName);
      final userBox = await Hive.openBox<User>(userBoxName);

      final userKey = sessionBox.get('currentUser');
      if (userKey == null) return null;

      return userBox.get(userKey);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
