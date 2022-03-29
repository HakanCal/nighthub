import 'package:flutter/material.dart';
import 'package:nighthub/src/settings.dart';
import 'package:provider/provider.dart';

import 'auth/authState.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key}) : super(key: key);

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
    const Settings()
  ];

  @override
  void initState() {
    super.initState();
  }

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    void _onItemTap(int index){
      setState(() => {_selectedIndex = index});
    }

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            title: const Text('Home Page'),
            leading: IconButton(
              onPressed: () {},
              icon: Image.asset('assets/nighthub.png'),
            ),
          ),
          body: false ? //arguments["isBusinessAccount"] ?  ///TODO: Here is where the different screens should be put: user account or business account
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AuthState>(context, listen: false).logOut();
                  Navigator.pushNamed(context, '/');
                },
                child: menuSelects[_selectedIndex],
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ) : Center(
              child: menuSelects[_selectedIndex]/*ElevatedButton(
                onPressed: () {
                  Provider.of<AuthState>(context, listen: false).logOut();
                  Navigator.pushNamed(context, '/');
                },
                child: menuSelects[_selectedIndex],
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  )
                ),
             */ ),
          bottomNavigationBar: NavBar(selectedIndex: _selectedIndex, onItemTap: _onItemTap),
        ),
      );
  }
}