// home_screen.dart

import 'package:parfumista/models/perfume.dart';
import 'package:parfumista/screens/perfume_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:parfumista/services/api_service.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';
import 'package:parfumista/screens/currency_converter_screen.dart';
import 'package:parfumista/screens/time_converter_screen.dart';
import 'package:parfumista/services/auth_service.dart';
import 'package:parfumista/models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final PerfumeApiService _perfumeApiService = PerfumeApiService();

  User? currentUser;
  List<Perfume> _perfumes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadRecommendedPerfumes();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadRecommendedPerfumes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil API untuk mendapatkan parfum rekomendasi
      final recommendedPerfumes = await _perfumeApiService.searchPerfumes('');
      setState(() {
        _perfumes = recommendedPerfumes;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk melakukan pencarian parfum
  Future<void> _searchPerfumes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results =
          await _perfumeApiService.searchPerfumes(_searchController.text);
      setState(() {
        _perfumes = results;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/frag.png',
              height: 40,
            ),
            SizedBox(width: 8),
            Text(
              'Parfumista',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CurrencyConverterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimeConverterScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.amber[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari Parfum',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchPerfumes(); // Panggil fungsi pencarian
                  }
                },
              ),
            ),
            // Welcome Message
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: Colors.amber[800],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Halo, ${currentUser?.username ?? "User"}!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _perfumes.length,
                      itemBuilder: (context, index) {
                        final perfume = _perfumes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PerfumeDetailScreen(perfume: perfume),
                              ),
                            );
                          },
                          child: Card(
                            child: Container(
                              color: Colors.white60,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Image.network(
                                      perfume.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            perfume.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            perfume.brand,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            '${perfume.rating.toStringAsFixed(1)} / 5',
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
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
