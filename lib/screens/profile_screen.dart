// ignore_for_file: unused_import, constant_identifier_names

import 'package:parfumista/screens/home_screen.dart';
import 'package:parfumista/screens/login_screen.dart';
import 'package:parfumista/services/auth_service.dart';
import 'package:parfumista/models/user.dart';
import 'package:flutter/material.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// Add enum for time zones
enum TimeZone { WIB, WITA, WIT, London }

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  User? currentUser;
  bool _isLoading = false;
  String? _profileImagePath;
  static const String _profileBoxName = 'profile_preferences';
  static const String _profileImageKey = 'profile_image_path';

  TimeZone _selectedTimeZone = TimeZone.WIB;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserData();
    await _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();

      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      setState(() {
        currentUser = user;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data profil')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final box = await Hive.openBox(_profileBoxName);
      final userKey = currentUser?.key.toString() ?? '';
      final imagePath = box.get('${_profileImageKey}_$userKey');

      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isLoading = true;
      });

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String userKey = currentUser?.key.toString() ?? 'default';
      final String fileName =
          'profile_${userKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${appDir.path}/$fileName';

      await File(pickedFile.path).copy(filePath);

      if (_profileImagePath != null) {
        final oldFile = File(_profileImagePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final box = await Hive.openBox(_profileBoxName);
      await box.put('${_profileImageKey}_$userKey', filePath);

      setState(() {
        _profileImagePath = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupload foto profil')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logoutUser() async {
    try {
      await _authService.logout();

      final box = await Hive.openBox(_profileBoxName);
      final userKey = currentUser?.key.toString() ?? '';
      await box.delete('${_profileImageKey}_$userKey');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return _convertToTimeZone(dateTime, _selectedTimeZone);
  }

  String _convertToTimeZone(DateTime dateTime, TimeZone zone) {
    late DateTime convertedTime;
    String zoneName;

    switch (zone) {
      case TimeZone.WIB:
        // WIB (UTC+7)
        convertedTime = dateTime.toUtc().add(Duration(hours: 7));
        zoneName = 'WIB';
        break;
      case TimeZone.WITA:
        // WITA (UTC+8)
        convertedTime = dateTime.toUtc().add(Duration(hours: 8));
        zoneName = 'WITA';
        break;
      case TimeZone.WIT:
        // WIT (UTC+9)
        convertedTime = dateTime.toUtc().add(Duration(hours: 9));
        zoneName = 'WIT';
        break;
      case TimeZone.London:
        // London (UTC+0/+1 depending on DST)
        final bool isDST = dateTime.timeZoneOffset.inHours != 0;
        convertedTime = dateTime.toUtc().add(Duration(hours: isDST ? 1 : 0));
        zoneName = 'London${isDST ? ' BST' : ' GMT'}';
        break;
    }

    return '${convertedTime.day}/${convertedTime.month}/${convertedTime.year} '
        '${convertedTime.hour.toString().padLeft(2, '0')}:'
        '${convertedTime.minute.toString().padLeft(2, '0')} '
        '$zoneName';
  }

  Widget _buildTimeZoneSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.amber),
      ),
      child: DropdownButton<TimeZone>(
        value: _selectedTimeZone,
        isExpanded: true,
        underline: SizedBox(),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14.0,
        ),
        items: TimeZone.values.map((TimeZone zone) {
          return DropdownMenuItem<TimeZone>(
            value: zone,
            child: Text(zone.toString().split('.').last),
          );
        }).toList(),
        onChanged: (TimeZone? newZone) {
          if (newZone != null) {
            setState(() {
              _selectedTimeZone = newZone;
            });
          }
        },
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickAndSaveImage,
          child: CircleAvatar(
            radius: 50.0,
            backgroundColor: Colors.grey[300],
            backgroundImage: _profileImagePath != null &&
                    File(_profileImagePath!).existsSync()
                ? FileImage(File(_profileImagePath!)) as ImageProvider
                : AssetImage('assets/default_profile.png'),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
        title: Text(
          'Profil Saya',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.amber[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 120),
                    _buildProfileImage(),
                    SizedBox(height: 16.0),
                    Text(
                      currentUser?.username ?? '',
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    _buildTimeZoneSelector(),
                    SizedBox(height: 8.0),
                    Text(
                      'Last Login: ${_formatDateTime(currentUser?.lastLogin ?? DateTime.now())}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Divider(
                      color: Colors.teal[200],
                      thickness: 1.0,
                      indent: 20.0,
                      endIndent: 20.0,
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text("Konfirmasi Logout"),
                              content: Text("Apakah Anda yakin ingin logout?"),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "Batal",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _logoutUser();
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
                      icon: Icon(Icons.logout, color: Colors.black),
                      label: Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16.0),
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
