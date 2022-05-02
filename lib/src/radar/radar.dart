import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nighthub/src/radar/radaritem.dart';
import 'package:nighthub/src/radar/radarlist.dart';
import "package:firebase_storage/firebase_storage.dart";

class Radar extends StatefulWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Radar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Radar();
}

class _Radar extends State<Radar> {

  late Position _userPos;
  List<RadarItem> _radarItems = <RadarItem>[];
  late Iterable<DataSnapshot> _businesses;
  late Future<void> _radarItemsSnapshot;
  String _sortMethod = 'distance';
  bool _sortOrder = false;
  Icon _sortIcon = Icon(Icons.south);
  double _userRadius = 100.0;

  Future<Position> _getUserPosition() async {
    print("Getting user location...");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
      return Future.error('Location services are disabled.');
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
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("Got user location!");
    return Geolocator.getCurrentPosition();
  }

  Future<Image> _getProfilepicture(String filename) async {
    Uint8List? imageBytes = await widget.storage
        .ref('profile_pictures/$filename')
        .getData(10000000);
    Image image =
        Image.asset('assets/nighthub.png'); // Default Logo of RadarItem
    if (imageBytes != null) {
      image = Image.memory(imageBytes);
    }
    return image;
  }

  Future<Iterable<DataSnapshot>> _getBusinesses() async {
    print('Accessing Database...');
    FirebaseDatabase database = FirebaseDatabase.instance;
    database.databaseURL =
        "https://nighthub-77c81-default-rtdb.europe-west1.firebasedatabase.app";
    print('Querying Database for Businesses...');
    Query query =
        database.ref('user_accounts').orderByChild('business').equalTo(true);
    DataSnapshot event = await query.get();
    print("Businesses loaded!");
    return event.children;
  }

  Future<List<RadarItem>> _getFilteredList(Position userPos, Iterable<DataSnapshot> businesses) async{
    List<RadarItem> radarItems = <RadarItem>[];
    print("Getting radar items...");
    for (DataSnapshot business in businesses) {
      // If this business has no geopoint data
      if (!business.hasChild("point/geopoint")) {
        print(business.value);
        continue;
      }
      double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          business.child("point/geopoint/latitude").value as double,
          business.child("point/geopoint/longitude").value as double
      );
      distance /= 1000; // meters to kilometer

      // Filter out all Businesses that are not within users selected Radius
      // Here we skip this business from the list
      if(distance > _userRadius) continue;
      print("Business ${business.child("username").value} is ${distance}km away");

      Image _logo = await _getProfilepicture(business.child("profile_picture").value as String);
      //Image _logo = Image.asset("assets/nighthub.png");
      radarItems.add(RadarItem(
          name: business.child("username").value as String,
          logo: _logo,
          address: business.child("address").value as String,
          distance: distance,
          categories: business.child("interests").value as List,
          rating: 1));
    }
    print(radarItems);
    print("Loaded Radar Items");
    return radarItems;
  }

  Future<void> _refreshList() async {
    setState(() {
      _radarItemsSnapshot = _initRadarItems();
    });
  }

  void _toggleSort() {
    setState(() {
      // True == ascending
      _sortOrder = !_sortOrder;
      _sortIcon = _sortOrder ? Icon(Icons.south) :  Icon(Icons.north);
      if (_sortOrder) {
        _radarItems.sort((a, b) => a.distance.compareTo(b.distance));
      } else {
        _radarItems.sort((a, b) => b.distance.compareTo(a.distance));
      }
    });
  }

  @override
  void initState(){
    print("Initialising Radar widget...");
    super.initState();
    _radarItemsSnapshot = _initRadarItems();
  }

  Future<void> _initRadarItems() async{
    print("Doing some Future work");
    _userPos = await _getUserPosition();
    _businesses = await _getBusinesses();
    _getFilteredList(_userPos, _businesses).then((radarItems) =>
    {
      setState((){
        _radarItems = radarItems;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Top bar menu for sorting method and order of RadarItems
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(children: [
            IconButton(
              icon: _sortIcon,
              onPressed: _toggleSort
          ),
            const Text('Distance'),
          Column(
            children: [
              Slider(
                value: _userRadius,
                max: 100.0,
                divisions: 10,
                label: _userRadius.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _userRadius = value;
                    _refreshList();
                  });
                },
              ),
              Text("Search radius: ${_userRadius.round().toString()}")
            ],
          )


          ])),
      // List with Shops
      FutureBuilder<void>(
          future: _radarItemsSnapshot,
          builder:
              (BuildContext context, AsyncSnapshot<void> snapshot){
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                  {
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }
                  case ConnectionState.done:
                    print("Future is done!");
                    print(_radarItems);
                    // Here we can work with future data

                    return Expanded(
                      flex: 1,
                      child: Scrollbar(
                          isAlwaysShown: false,
                          //always show scrollbar
                          thickness: 10,
                          //width of scrollbar
                          radius: const Radius.circular(20),
                          //corner radius of scrollbar
                          scrollbarOrientation: ScrollbarOrientation.left,
                          child: RefreshIndicator(
                              child: RadarList(radarItems: _radarItems),
                              onRefresh:
                                  _refreshList // refreshes list content on swiping down
                              )),
                    );
            }
          })
    ]);
  }
}
