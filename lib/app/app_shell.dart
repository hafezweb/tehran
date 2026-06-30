import 'package:flutter/material.dart';

import '../features/feed/feed_screen.dart';
import '../features/map/screens/map_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/feed/widgets/mini_player.dart';

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

    pages = [MapScreen(), FeedScreen(), ProfileScreen()];
  }

  Widget navItem(IconData icon, String title, int i) {
    final selected = index == i;

    return GestureDetector(
      onTap: () {
        setState(() {
          index = i;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white38),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: pages),

          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(.08))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.map, "نقشه", 0),
            navItem(Icons.feed, "فید", 1),
            navItem(Icons.person, "پروفایل", 2),
          ],
        ),
      ),
    );
  }
}
