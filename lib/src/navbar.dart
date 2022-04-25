import 'package:flutter/material.dart';
import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import 'auth/authState.dart';
import 'auth/authFlowScreens.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    required this.selectedIndex,
    required this.onItemTap,
  });

  final int selectedIndex;
  final void Function(int index) onItemTap;

  @override
  _NavBar createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.local_bar_rounded, color: Colors.orangeAccent),
            label: 'Discover',
            tooltip: 'Discover local Bars!'),
        BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop_rounded, color: Colors.orangeAccent),
            label: 'Near me',
            tooltip: 'Local Bars near me'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.orangeAccent),
            label: 'Settings',
            tooltip: 'Settings')
      ],
      backgroundColor: Colors.black,
      iconSize: 24,
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTap,
      showSelectedLabels: false,
    );
  }
}