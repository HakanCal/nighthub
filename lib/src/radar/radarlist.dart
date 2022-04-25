import 'package:flutter/material.dart';
import 'package:nighthub/src/radar/radaritem.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart' as fbd;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:geolocator/geolocator.dart';

class RadarList extends StatefulWidget{
  const RadarList({this.sortMethod = 'distance' ,Key? key}) : super(key: key);
  final String sortMethod;

  @override
  State<StatefulWidget> createState() => _RadarList();
}



class _RadarList extends State<RadarList>{

  late Position _userPos;
  List<RadarItem> _radarItems = [];
  final Image _logo = Image.network('https://logos-download.com/wp-content/uploads/2016/05/Coffeeshop_Company_logo_logotype.png');
  /*
  const Position(
      latitude: 48.783333,
      longitude: 9.183333,
      accuracy: 1.0,
      altitude: 1,
      speedAccuracy: 1.0,
      timestamp: null,
      speed: 1.0,
      heading: 1.0
  ); */

  @override
  void initState() {
    _updateRadarItems();
    super.initState();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
      //return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.'
      );
    }

    return await Geolocator.getCurrentPosition();
  }


  Future<Image> _getProfilepicture(String filename) async{

    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    String downloadURL = await storage.ref().child('profile_pictures/$filename').getDownloadURL();
    return Image.network(downloadURL);
  }

  Future<List<RadarItem>> _getRadarItems() async {

    List<RadarItem> radarItems = [];
    print('getting new items...');
    await Firebase.initializeApp();
    _userPos = await _determinePosition();

    print('accessing realtime database...');
    fbd.FirebaseDatabase database = fbd.FirebaseDatabase.instance;
    database.databaseURL = "https://nighthub-77c81-default-rtdb.europe-west1.firebasedatabase.app";

    // Query only user accounts with business set true
    print('querying for businesses...');
    fbd.Query query = database.ref('user_accounts').orderByChild('business').equalTo(true);
    fbd.DataSnapshot event = await query.get();

    // Add all the business to the list
    event.children.forEach((user_account) async{
      print(user_account.value);
      // Distance from business to user location in kilometers
      double distance = Geolocator.distanceBetween(
          _userPos.latitude,
          _userPos.longitude,
          user_account.child("point/geopoint/longitude").value as double,
          user_account.child("point/geopoint/latitude").value as double
      ) / 1000;
      Image __logo = await _getProfilepicture(user_account.child("profile_picture").value as String);
      radarItems.add(
          RadarItem(
            name: user_account.child("username").value as String,
            logo: __logo,
            address: user_account.child("address").value as String,
            distance: distance,
            categories: user_account.child("interests").value as List,
            rating: 1
          )
      );
    });
    // Sorts radaritem list by distance or whatever sormethod radar instance was called with
    sortBy(widget.sortMethod, radarItems);
    return radarItems;
  }

  sortBy(String sortMethod, List<RadarItem> radarItems){
    switch(sortMethod){
      case 'distance':
        radarItems.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'rating':
        radarItems.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
  }

  Future<void> _updateRadarItems() async{
    _radarItems = await _getRadarItems();
    setState((){});
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              RadarItem radaritem = _radarItems[index];
              return radaritem;
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _radarItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            }
        ),
        onRefresh: _updateRadarItems // refreshes list content on swiping down
    );
  }
}