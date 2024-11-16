import 'package:parfumista/screens/perfume_detail_screen.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parfumista/providers/favorite_provider.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        color: Colors.amber[50],
        child: Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, child) {
            final favorites = favoriteProvider.favorites;
            if (favorites.isEmpty) {
              return Center(
                child: Text('No favorite perfumes yet'),
              );
            }
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final perfume = favorites[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      perfume.imageUrl,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(perfume.name),
                    subtitle: Text(perfume.brand),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        favoriteProvider.removeFavorite(perfume);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PerfumeDetailScreen(perfume: perfume),
                      ));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: DynamicBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigate to corresponding screens
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
