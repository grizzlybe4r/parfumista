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

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.lastLogin,
  });
}
