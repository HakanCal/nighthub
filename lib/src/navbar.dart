import 'package:flutter/material.dart';
import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import 'auth/authState.dart';
import 'auth/authFlowScreens.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    required this.selectedIndex,
    required this.onItemTap,
    required this.isBusinessAccount,
  });

  final int selectedIndex;
  final bool isBusinessAccount;
  final void Function(int index) onItemTap;

  @override
  _NavBar createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined, color: Colors.orangeAccent),
            label: 'Discover',
            tooltip: 'Discover local Bars!'),
        widget.isBusinessAccount ? const BottomNavigationBarItem(
            icon: Icon(Icons.pentagon_outlined, color: Colors.orangeAccent),
            label: 'Page settings',
            tooltip: 'Page settings') :
        const BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop_rounded, color: Colors.orangeAccent),
            label: 'Near me',
            tooltip: 'Local Bars near me'),
        const BottomNavigationBarItem(
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