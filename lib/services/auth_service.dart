// ignore_for_file: unused_local_variable

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/user.dart';
import 'dart:io';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionBoxName = 'session';
  static const String profileBoxName = 'profile_preferences';

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

      // Simpan user baru dengan profileImagePath null
      final user = User(
        username: username,
        password: encryptedPassword,
        email: email,
        lastLogin: DateTime.now(),
        profileImagePath: null,
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

      // Update last login menggunakan method dari model User
      user.updateLastLogin();

      // Save session
      await sessionBox.put('currentUser', user.key);

      return user;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Update profile image
  Future<bool> updateUserProfileImage(String imagePath) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Delete old profile image if exists
      if (user.profileImagePath != null) {
        final oldFile = File(user.profileImagePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      // Update profile image path
      user.updateProfileImage(imagePath);
      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  // Clear profile image
  Future<bool> clearUserProfileImage() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Delete profile image file
      if (user.profileImagePath != null) {
        final imageFile = File(user.profileImagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      // Clear profile image path
      user.clearProfileImage();
      return true;
    } catch (e) {
      print('Error clearing profile image: $e');
      return false;
    }
  }

  // Update user information
  Future<bool> updateUserInfo({String? newEmail}) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      if (newEmail != null && newEmail.trim().isNotEmpty) {
        // Check if email is already used by another user
        final box = await Hive.openBox<User>(userBoxName);
        if (box.values.any((otherUser) =>
            otherUser.key != user.key &&
            otherUser.email.toLowerCase() == newEmail.toLowerCase())) {
          return false;
        }
        user.email = newEmail.trim();
      }

      await user.save();
      return true;
    } catch (e) {
      print('Error updating user info: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final sessionBox = await Hive.openBox(sessionBoxName);
      await sessionBox.clear();

      // Clear profile related preferences
      final profileBox = await Hive.openBox(profileBoxName);
      await profileBox.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final sessionBox = await Hive.openBox(sessionBoxName);
      final hasUser = sessionBox.containsKey('currentUser');
      if (hasUser) {
        // Verify that the user still exists
        final user = await getCurrentUser();
        return user != null;
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final sessionBox = await Hive.openBox(sessionBoxName);
      final userBox = await Hive.openBox<User>(userBoxName);

      final userKey = sessionBox.get('currentUser');
      if (userKey == null) return null;

      final user = userBox.get(userKey);
      if (user == null) {
        // Clean up invalid session
        await sessionBox.delete('currentUser');
      }

      return user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Delete profile image if exists
      await clearUserProfileImage();

      // Delete user from userBox
      final userBox = await Hive.openBox<User>(userBoxName);
      await user.delete();

      // Clear session
      await logout();

      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Verify old password
      final encryptedOldPassword = _encryptPassword(oldPassword);
      if (user.password != encryptedOldPassword) {
        return false;
      }

      // Update to new password
      user.password = _encryptPassword(newPassword);
      await user.save();

      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}
