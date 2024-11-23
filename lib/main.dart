import 'package:parfumista/models/user.dart';
import 'package:parfumista/providers/favorite_provider.dart';
import 'package:parfumista/screens/favorite_screen.dart';
import 'package:parfumista/screens/feedback_screen.dart';
import 'package:parfumista/screens/home_screen.dart';
import 'package:parfumista/screens/profile_screen.dart';
import 'package:parfumista/screens/splash_screen.dart';
import 'package:parfumista/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter(UserAdapter());

  await Hive.openBox<User>(AuthService.userBoxName);
  await Hive.openBox(AuthService.sessionBoxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Katalog Parfum',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/feedback': (context) => FeedbackScreen(),
          '/favorite': (context) => FavoriteScreen(),
          '/splash': (context) => SplashScreen(),
        });
  }
}
