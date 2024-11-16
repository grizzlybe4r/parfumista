import 'package:flutter/material.dart';
import 'package:parfumista/models/perfume.dart';

class FavoriteProvider with ChangeNotifier {
  List<Perfume> _favorites = [];

  List<Perfume> get favorites => _favorites;

  bool isFavorite(Perfume perfume) {
    return _favorites.contains(perfume);
  }

  void addFavorite(Perfume perfume) {
    _favorites.add(perfume);
    notifyListeners();
  }

  void removeFavorite(Perfume perfume) {
    _favorites.remove(perfume);
    notifyListeners();
  }
}
