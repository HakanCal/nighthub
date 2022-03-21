import 'package:flutter/material.dart';

import 'auth/loginScreen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  static const List <Widget> _menuSelects = <Widget>[
    //Swiper
    //Near me
    //Setting
    Text('Select 0'),
    Text('Select 1'),
    Text('Select 2')
  ];
  int _selectedIndex = 0;
  void onItemTap(int index){
    setState(()=>{_selectedIndex = index});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('NightHub')), //TODO: perhaps Burgericon or so
        body: Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: _menuSelects[_selectedIndex])),
        bottomNavigationBar:
        BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.local_bar_rounded, color: Colors.red),
                label: 'Discover',
                tooltip: 'Discover local Bars!'),
            BottomNavigationBarItem(
                icon: Icon(Icons.pin_drop_rounded, color: Colors.red),
                label: 'Near me',
                tooltip: 'Local Bars near me'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings, color: Colors.orange),
                label: 'Settings',
                tooltip: 'Settings')
          ],
          backgroundColor: Colors.black,
          iconSize: 24,
          currentIndex: _selectedIndex,
          onTap: onItemTap,
        )
    );
  }
}