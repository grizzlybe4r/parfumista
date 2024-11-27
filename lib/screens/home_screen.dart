import 'package:parfumista/models/perfume.dart';
import 'package:parfumista/screens/perfume_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:parfumista/services/api_service.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';
import 'package:parfumista/screens/currency_converter_screen.dart';
import 'package:parfumista/screens/time_converter_screen.dart';
import 'package:parfumista/services/auth_service.dart';
import 'package:parfumista/models/user.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final PerfumeApiService _perfumeApiService = PerfumeApiService();
  Timer? _debounceTimer;

  User? currentUser;
  List<Perfume> _perfumes = [];
  List<Perfume> _allPerfumes = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showNoResults = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadRecommendedPerfumes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    _perfumeApiService.dispose(); // Bersihkan resources API service
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchPerfumes(_searchController.text);
      } else {
        _loadRecommendedPerfumes();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print('Error loading user: $e');
      // Tidak perlu menampilkan error ke user untuk loading user
    }
  }

  Future<void> _loadRecommendedPerfumes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _showNoResults = false;
    });

    try {
      final recommendedPerfumes = await _perfumeApiService.searchPerfumes('');
      setState(() {
        _perfumes = recommendedPerfumes;
        _allPerfumes = recommendedPerfumes;
        _showNoResults = recommendedPerfumes.isEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat parfum rekomendasi. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPerfumes(String query) async {
    if (query.trim().isEmpty) {
      _loadRecommendedPerfumes();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _showNoResults = false;
    });

    try {
      if (_allPerfumes.isNotEmpty) {
        final localResults = _performLocalSearch(query);
        if (localResults.isNotEmpty) {
          setState(() {
            _perfumes = localResults;
            _isLoading = false;
          });
          return; // Keluar jika hasil lokal ditemukan
        }
      }

      final results = await _perfumeApiService.searchPerfumes(query);
      setState(() {
        _perfumes = results;
        _showNoResults = results.isEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Terjadi kesalahan saat mencari parfum. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Perfume> _performLocalSearch(String query) {
    query = query.toLowerCase();
    return _allPerfumes.where((perfume) {
      return perfume.name.toLowerCase().contains(query) ||
          perfume.brand.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendedPerfumes,
              child: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
          ],
        ),
      );
    }

    if (_showNoResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada parfum yang ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _perfumes.length,
      itemBuilder: (context, index) {
        final perfume = _perfumes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfumeDetailScreen(perfume: perfume),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        perfume.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${perfume.rating.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                  builder: (context) => CurrencyConverterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimeConverterScreen(),
                ),
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
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari Parfum',
                  hintText: 'Masukkan nama atau brand parfum...',
                  prefixIcon: Icon(Icons.search, color: Colors.amber),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadRecommendedPerfumes();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.amber, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
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
              child: _buildSearchResults(),
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
