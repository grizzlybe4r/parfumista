// profile_screen.dart
// ignore_for_file: prefer_const_constructors, unused_import

import 'package:parfumista/screens/home_screen.dart';
import 'package:parfumista/screens/login_screen.dart';
import 'package:parfumista/services/auth_service.dart'; // Import AuthService
import 'package:flutter/material.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;

  Future<void> _logoutUser() async {
    // Panggil AuthService.logout untuk menghapus sesi
    await AuthService().logout();

    // Arahkan pengguna ke LoginScreen setelah logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.amberAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              'Profil Saya',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.amber[50],
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('assets/profile_image.jpg'),
              ),
              SizedBox(height: 16.0),
              Text(
                'Nasywan Jibran Aryadi',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'NIM : 124220038',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.0),
              Divider(
                color: Colors.teal[200],
                thickness: 1.0,
                indent: 20.0,
                endIndent: 20.0,
              ),
              SizedBox(height: 8.0),
              ListTile(
                leading: Icon(Icons.cake, color: Colors.teal),
                title: Text(
                  'TTL: Kulon Progo, 27 Desember 2002',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(height: 50.0),
              ElevatedButton.icon(
                onPressed: () {
                  // Tampilkan dialog konfirmasi
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Konfirmasi Logout"),
                        content: Text("Apakah Anda yakin ingin logout?"),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop(); // Tutup dialog
                              await _logoutUser(); // Logout user dan arahkan ke LoginScreen
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                label: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: DynamicBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/favorite');
              break;
            case 2:
              Navigator.pushNamed(context, '/feedback');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
