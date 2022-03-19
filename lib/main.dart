import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Navigation bar Test',
        home: Menu()
    );
  }
}


class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _Menu();
}

class _Menu extends State<Menu> {

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
        appBar: AppBar(title: const Text('Navigation bar for nighthub')),
        body: Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginWidget()));
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