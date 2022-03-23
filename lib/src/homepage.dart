import 'package:flutter/material.dart';
import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import 'auth/authState.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final List <Widget> menuSelects = <Widget>[
    //Swiper
    //Near me
    //Setting
    const Text('LOG OUT'), //TODO: What we want in the screens
    const Text('Select 1'),
    const Text('Select 2')
  ];

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    void _onItemTap(int index){
      setState(() => {_selectedIndex = index});}

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text('Home Page'),
          ),
          body: Center(
              child: ElevatedButton(
                  onPressed: () {
                    Provider.of<AuthState>(context, listen: false).logOut();
                    Navigator.pushNamed(context, '/');
                  },
                  child: menuSelects[_selectedIndex])),
          bottomNavigationBar: NavBar(selectedIndex: _selectedIndex, onItemTap: _onItemTap),
        ),
    );
  }
}