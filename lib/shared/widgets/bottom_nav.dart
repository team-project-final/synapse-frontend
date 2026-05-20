import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const routes = ['/', '/notes', '/decks'];

  static int indexFromRoute(String route) {
    if (route == '/') return 0;
    if (route.startsWith('/notes')) return 1;
    if (route.startsWith('/decks') || route.startsWith('/review')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex.clamp(0, 3),
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈'),
        NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: '노트'),
        NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: '복습'),
        NavigationDestination(icon: Icon(Icons.menu), label: '더보기'),
      ],
    );
  }
}
