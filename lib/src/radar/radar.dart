import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nighthub/src/radar/radaritem.dart';
import 'package:nighthub/src/radar/radarlist.dart';
import "package:firebase_storage/firebase_storage.dart";
import 'package:multiselect/multiselect.dart';


class Radar extends StatefulWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final options = [
    'Nightclub',
    'Dance',
    'Club',
    'Bar',
    'Night Life',
    'Live Music',
    'Latin',
    'Festival',
    'Event',
    'Drinks',
    'Cafe',
    'Rock',
    'Jazz',
    'Metal',
    'EDM',
    'Pop',
    'Techno',
    'Electro',
    'Hip Hop',
    'Rap',
    'Punk'
  ];

  Radar({Key? key}) : super(key: key);
  static const double MAX_DISTANCE = 100;

  @override
  State<StatefulWidget> createState() => _Radar();
}

class _Radar extends State<Radar> {
  late Position _userPos;
  List<RadarItem> _completeList = <RadarItem>[];
  late Iterable<DataSnapshot> _businesses;
  late Future<void> _future;

  // Location permissions
  late bool _serviceEnabled;
  late LocationPermission _permission;

  // Filter variables
  List<RadarItem> _shownList = [];
  List<String> _interests = ["latin"];
  double _ratingFilterValue = 0;
  double _userRadius = 100.0;

  //Toggling variables
  //String _sortMethod = 'distance';
  bool _sortOrder = true;
  Icon _sortIcon = const Icon(Icons.north);

  Future<Position> _getUserPosition() async {
    print("Getting user location...");

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.requestPermission();
      return Future.error('Location services are disabled.');
    }

    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("Got user location!");
    return Geolocator.getCurrentPosition();
  }

  //Database Image fetch
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

  //Database fetch
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

  // Creating List
  Future<List<RadarItem>> _getCompleteList(
      Position userPos, Iterable<DataSnapshot> businesses) async {
    List<RadarItem> radarItems = <RadarItem>[];
    print("Getting radar items...");
    for (DataSnapshot business in businesses) {
      // If this business has no geopoint data
      if (!business.hasChild("point/geopoint")) {
        continue;
      }
      double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          business.child("point/geopoint/latitude").value as double,
          business.child("point/geopoint/longitude").value as double);
      distance /= 1000; // meters to kilometer

      // Filter out all Businesses that are not within Max radius
      // Here we skip this business from the list
      if (distance > Radar.MAX_DISTANCE) continue;
      print("Business ${business.child("username").value} is ${distance}km away");
      print(business.child("interests").value as List<dynamic>);
      Image _logo = await _getProfilepicture(
          business.child("profile_picture").value as String);
      //Image _logo = Image.asset("assets/nighthub.png");
      radarItems.add(RadarItem(
          name: business.child("username").value as String,
          logo: _logo,
          address: business.child("address").value as String,
          distance: distance,
          categories: business.child("interests").value as List<dynamic>,
          rating: 1));
    }
    print("Loaded Radar Items");
    return radarItems;
  }

  Future<void> _initFuture() async {
    //print("Doing some Future work");
    _userPos = await _getUserPosition();
    _businesses = await _getBusinesses();
    _completeList = await _getCompleteList(_userPos, _businesses);
    _shownList = _completeList;
  }

  @override
  void initState() {
    print("Initialising Radar widget...");
    _future = _initFuture();
    super.initState();
  }

  Future<void> _refreshList() async {
    setState(() {
      _future = _initFuture();
    });
  }
  List<RadarItem> applyFilter(List<RadarItem> completeList){
    print("Complete List");
    print(completeList);
    print(_completeList);
    print("Filtering by distance");
    List<RadarItem> filteredList = distanceFilter(completeList);
    print(filteredList);
    // print("Filtering by category / interest");
    //filteredList = interestFilter(filteredList);
    //print(filteredList);
    return filteredList;
  }
  //TODO CATEGORIES IS DYNAMIC LIST TYPE THIS CHECK DOES NOT WORK AND RETURN EMPTY ARRAY
  List<RadarItem> interestFilter( List<RadarItem> shownList) {
    List<RadarItem> filteredList = shownList;
    if (_interests.isNotEmpty) {
      filteredList = [];
      for(RadarItem item in shownList){
        for(String interest in _interests){
          if(item.categories.contains(interest)){ ///DOES NOT WORK
            filteredList.add(item);
          }
        }
      }
    }
    return filteredList;
  }

  List<RadarItem> distanceFilter(List<RadarItem> list) {
    return list.where((item) => item.distance < _userRadius).toList();
  }

  List<RadarItem> ratingFilter(List<RadarItem> items) {
     return items
        .where((item) => item.rating > _ratingFilterValue)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Top bar menu for sorting method and order of RadarItems
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(children: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(icon: _sortIcon, onPressed: (){
                      setState((){
                        _sortOrder = !_sortOrder;
                        _sortIcon = _sortOrder ? const Icon(Icons.north) : const Icon(Icons.south);
                        if (_sortOrder) {
                          _shownList.sort((a, b) => a.distance.compareTo(b.distance));
                        } else {
                          _shownList.sort((a, b) => b.distance.compareTo(a.distance));
                        }
                        print("List is sorted  ${_sortOrder ? "ascending" : "descending"}");
                      });
                    }),
                    const Text('Distance'),
                  ],
                ),
                /*Row(
                  children: [
                    IconButton(icon: Icon(Icons.filter_alt_rounded), onPressed: (){
                      setState((){

                      });
                    }),
                    DropDownMultiSelect(
                      onChanged: (List<String> x) {
                        setState(() {
                          // DO SOMETHING HERE
                        });
                      },
                      options: widget.options,
                      selectedValues: _interests,
                      whenEmpty: 'Select Interests',
                    )
                  ]
                )*/
              ],
            ),
            Column(
              children: [
                Slider(
                  activeColor: Colors.orange,
                  value: _userRadius,
                  max: 100.0,
                  divisions: 10,
                  label: _userRadius.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _userRadius = value;
                      _shownList = applyFilter(_completeList);
                    });
                  },
                ),
                Text("Search radius: ${_userRadius.round().toString()}km")
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: (){},
                ),
                const Text("Favorites")
              ],
            )
          ])),
      const SizedBox(height: 10),
      // List with Shops
      FutureBuilder<void>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                {
                  return const Expanded(
                    child: Center(
                        child: SpinKitFadingCircle(
                      color: Colors.orange,
                      size: 60,
                    )),
                  );
                }
              case ConnectionState.done:
                String error = "";
                if (_completeList.isEmpty) {
                  error = "Nothing nearby";
                }
                if (!_serviceEnabled) {
                  error = "Location service is disabled";
                } else if (_permission == LocationPermission.denied ||
                    _permission == LocationPermission.deniedForever) {
                  error = "Location service has no permission";
                }
                if (error.isNotEmpty) {
                  return Expanded(
                      child: Center(
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.error_outline_rounded),
                      Text(error),
                    ],
                  )));
                }

                // Here we can work with future data

                _shownList = _shownList.where((element) => element.distance < _userRadius).toList();

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
                          child: RadarList(radarItems: _shownList),
                          onRefresh:
                              _refreshList // refreshes list content on swiping down
                          )),
                );
            }
          })
    ]);
  }
}
