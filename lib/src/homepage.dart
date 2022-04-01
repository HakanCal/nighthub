import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:nighthub/src/settings.dart';

import 'auth/authState.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late final List <Widget> menuSelects;

  late Future<dynamic> _future;

  Map<String, dynamic> _accountData = <String, dynamic>{};
  Map<String, dynamic> get accountData => _accountData;
  File? _tempImageFile;

  @override
  void initState() {
    _future = getUserData();
    super.initState();
  }

  var _selectedIndex = 0;

  /// Get all the user-related information and load profile picture
  Future<dynamic> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
    .collection('user_accounts')
    .where('userId', isEqualTo: userId)
    .get()
    .then((value) => {
      for (final document in value.docs) {
        setState(() {
          _accountData = document.data();
        })
      }
    }).then((value) => getImageFile());
  }

  /// Preloads the profile picture from Firebase Storage
  Future<dynamic> getImageFile() async {
    if (accountData.isNotEmpty) {
      String imageName = accountData['profile_picture'];
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$imageName');

      setState(() {
        _tempImageFile = tempFile;
          menuSelects = <Widget>[
            //Swiper
            //Near me
            //Setting
            const Text('LOG OUT'), //TODO: What we want in the screens
            const Text('Select 1'),
            AppSettings(userData: accountData)
          ];
      });

      /// If file doesn't exist, it will try downloading
      if (!tempFile.existsSync()) {
        try {
          tempFile.create(recursive: true);
          await firebase_storage.FirebaseStorage.instance.ref('/profile_pictures/$imageName').writeToFile(tempFile);
        } catch (e) {
          /// If there is an error the created file will be deleted
          await tempFile.delete(recursive: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    void _onItemTap(int index){
      setState(() => {_selectedIndex = index});
    }

    return FutureBuilder<dynamic>(
        future: _future,
        builder: (context, snapshot) {
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
              body: false ? //arguments["isBusinessAccount"] ?

              ///TODO: Here is where the different screens should be put: user account or business account
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<AuthState>(context, listen: false).logOut();
                    Navigator.pushNamed(context, '/');
                  },
                  child: menuSelects[_selectedIndex],
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    )
                  ),
                ),
              */),
              bottomNavigationBar: NavBar(
                selectedIndex: _selectedIndex, onItemTap: _onItemTap
              ),
            ),
          );
        }
    );
  }
}