import 'package:flutter/material.dart';

class DynamicBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const DynamicBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final primaryColor = Colors.amber[50];
    final onSurfaceColor = Colors.black;

    // Helper function to build BottomNavigationBarItem
    BottomNavigationBarItem buildNavItem(
        IconData iconData, String label, int index) {
      return BottomNavigationBarItem(
        icon: Icon(
          iconData,
          color: currentIndex == index ? primaryColor : onSurfaceColor,
          size: 24.0,
        ),
        label: label,
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      backgroundColor: Colors.amber,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      iconSize: 30.0,
      selectedFontSize: 18.0,
      unselectedFontSize: 14.0,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      items: [
        buildNavItem(Icons.home, 'Home', 0),
        buildNavItem(Icons.favorite, 'Favorite', 1),
        buildNavItem(Icons.feedback, 'Feedback', 2),
        buildNavItem(Icons.person, 'Profile', 3),
      ],
    );
  }
}
