import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nighthub/src/discover/editEntityPage.dart';
import 'package:nighthub/src/favorites/favorites.dart';
import 'package:nighthub/src/settings/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'discover/discover.dart';
import 'navbar.dart';
import 'radar/radar.dart';
import 'settings/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late Future<dynamic> _future;

  Map<String, dynamic>? _accountData = <String, dynamic>{};

  Map<String, dynamic>? get accountData => _accountData;
  File? _tempImageFile;
  List<Widget> menuSelects = <Widget>[];
  late StreamSubscription<DatabaseEvent> _counterSubscription;

  @override
  void initState() {
    super.initState();
    _future = getUserData();
  }

  @override
  void dispose() {
    _counterSubscription.cancel();
    super.dispose();
  }

  var _selectedIndex = 0;

  /// Get all the user-related information and load profile picture
  Future<dynamic> getUserData() async {
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    _counterSubscription = realtimeDatabase
        .child('user_accounts/$userId/')
        .onValue
        .listen((event) async {
          if (event.snapshot.value != null) {
            Map<String, dynamic>? data = Map<String, dynamic>.from(event.snapshot.value as dynamic);
            setState(() {
              _accountData = data;
            });
            await getImageFile();
          }
    });
  }

  /// Preloads the profile picture from Firebase Storage
  Future<dynamic> getImageFile() async {
    if (accountData!.isNotEmpty == true) {
      String imageName = accountData!['profile_picture'];

      if (imageName != 'null') {
        final tempDir = await getTemporaryDirectory();
        final File tempFile = File('${tempDir.path}/$imageName');

        /// If file doesn't exist, it will try downloading
        if (tempFile.existsSync() == false) {
          try {
            tempFile.create(recursive: true);
            await firebase_storage.FirebaseStorage.instance
                .ref('/profile_pictures/$imageName')
                .writeToFile(tempFile);
          } catch (e) {
            /// If there is an error the created file will be deleted
            debugPrint(e.toString());
            await tempFile.delete(recursive: true);
          }
        }

        setState(() {
          _tempImageFile = tempFile;
          menuSelects = <Widget>[
            Discover(isBusiness: accountData!['business']),
            accountData!['business'] == true
                ? EditEntityPage(userData: accountData!)
                : Radar(),
            const Favorites(),
            AppSettings(userData: accountData!, profilePicture: _tempImageFile)
          ];
        });
      } else {
        setState(() {
          menuSelects = <Widget>[
            Discover(isBusiness: accountData!['business']),
            accountData!['business'] == true
                ? EditEntityPage(userData: accountData!)
                : Radar(), //TODO: FAVORITES
            const Favorites(),
            AppSettings(userData: accountData!, profilePicture: null)
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onItemTap(int index) {
      setState(() => {_selectedIndex = index});
    }

    return FutureBuilder<dynamic>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  title: const Text('nightHub'),
                  leading: IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/nighthub.png'),
                  ),
                ),
                body: Center(
                    child: menuSelects.isNotEmpty
                        ? menuSelects[_selectedIndex]
                        : null),
                bottomNavigationBar: NavBar(
                    selectedIndex: _selectedIndex,
                    onItemTap: _onItemTap,
                    isBusinessAccount:
                        accountData!['business'] == true ? true : false),
              ),
            );
          } else {
            return Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/nighthub.png',
                        width: 200, height: 200, fit: BoxFit.contain),
                    const SpinKitFadingCircle(
                      color: Colors.orange,
                      size: 60,
                    ),
                  ],
                ));
          }
        });
  }
}
