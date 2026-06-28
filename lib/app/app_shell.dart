import 'package:flutter/material.dart';
import '../features/map/screens/map_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      MapScreen(),
      FeedScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "نقشه"),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: "فید"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "پروفایل"),
        ],
      ),
    );
  }
}
