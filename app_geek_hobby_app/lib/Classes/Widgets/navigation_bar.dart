import 'package:app_geek_hobby_app/Pages/collections.dart';
import 'package:app_geek_hobby_app/Pages/explore.dart';
import 'package:app_geek_hobby_app/Pages/social.dart';
import 'package:app_geek_hobby_app/Pages/suggestions.dart';
import 'package:flutter/material.dart';

class MainTabScaffold extends StatefulWidget {
  @override
  _MainTabScaffoldState createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ExplorePage(),
    SuggestionsPage(),
    SocialPage(),
    CollectionsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 184, 55, 182),
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: 'Suggestions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Collections'),
        ],
      ),
    );
  }
}
