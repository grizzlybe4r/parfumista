import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  @HiveField(2)
  String email;

  @HiveField(3)
  DateTime lastLogin;

  @HiveField(4)
  String? profileImagePath;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.lastLogin,
    this.profileImagePath,
  });

  // Method untuk update profile image
  void updateProfileImage(String? path) {
    profileImagePath = path;
    save(); // Save perubahan ke Hive
  }

  // Method untuk clear profile image
  void clearProfileImage() {
    profileImagePath = null;
    save();
  }

  // Method untuk update last login
  void updateLastLogin() {
    lastLogin = DateTime.now();
    save();
  }

  // Method untuk convert user ke Map (berguna untuk export/debug)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'lastLogin': lastLogin.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  @override
  String toString() {
    return 'User{username: $username, email: $email, lastLogin: $lastLogin, hasProfileImage: ${profileImagePath != null}}';
  }
}
