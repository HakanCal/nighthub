import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nighthub/src/radar/radarItem.dart';
import 'package:nighthub/src/radar/radarlist.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Radar extends StatefulWidget {
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
  static const double maxDistance = 200;

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
  final List<String> _interests = [];
  final double _ratingFilterValue = 0;
  double _userRadius = Radar.maxDistance;

  //Toggling variables
  bool _sortOrder = true;
  Icon _sortIcon = const Icon(Icons.north);

  Future<Position> _getUserPosition() async {
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
    return Geolocator.getCurrentPosition();
  }

  //Database fetch
  Future<Iterable<DataSnapshot>> _getBusinesses() async {
    DatabaseReference database = FirebaseDatabase.instance.ref();
    Query query =
        database.child('user_accounts').orderByChild('business').equalTo(true);
    DataSnapshot event = await query.get();
    return event.children;
  }

  // Creating List
  Future<List<RadarItem>> _getCompleteList(
      Position userPos, Iterable<DataSnapshot> businesses) async {
    List<RadarItem> radarItems = <RadarItem>[];
    String primaryImageUrl = '';

    for (DataSnapshot business in businesses) {
      // If this business has no geopoint data
      if (!business.hasChild('point/geopoint')) {
        continue;
      }
      double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          business.child('point/geopoint/latitude').value as double,
          business.child('point/geopoint/longitude').value as double);
      distance /= 1000; // meters to kilometer

      // Filter out all Businesses that are not within Max radius
      // Here we skip this business from the list
      if (distance > Radar.maxDistance) continue;
      final businessPictures = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child(
              'business_pictures/${business.child('userId').value as String}')
          .listAll();

      if (businessPictures.items.isNotEmpty) {
        await businessPictures.items.last.getDownloadURL().then((value) {
          primaryImageUrl = value.toString();
        });

        radarItems.add(RadarItem(
            userID: business.child('userId').value as String,
            name: business.child('username').value as String,
            address: business.child('address').value as String,
            logo: primaryImageUrl,
            distance: distance,
            categories: business.child('interests').value as List<dynamic>,
            rating: 1));
      }
    }
    return radarItems;
  }

  Future<void> _initFuture() async {
    _userPos = await _getUserPosition();
    _businesses = await _getBusinesses();
    _completeList = await _getCompleteList(_userPos, _businesses);
    _shownList = _completeList;
  }

  @override
  void initState() {
    super.initState();
    _future = _initFuture();
  }

  Future<void> _refreshList() async {
    setState(() {
      _future = _initFuture();
    });
  }

  List<RadarItem> applyFilter(List<RadarItem> completeList) {
    List<RadarItem> filteredList = distanceFilter(completeList);
    return interestFilter(filteredList);
  }

  List<RadarItem> interestFilter(List<RadarItem> shownList) {
    List<RadarItem> filteredList = shownList;
    if (_interests.isNotEmpty) {
      filteredList = <RadarItem>[];
      for (RadarItem item in shownList) {
        for (dynamic interest in item.categories) {
          String interestString = interest as String;
          if (_interests.contains(interestString)) {
            filteredList.add(item);
            break;
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
    return items.where((item) => item.rating > _ratingFilterValue).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Top bar menu for sorting method and order of RadarItems
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
            icon: _sortIcon,
            onPressed: () {
              setState(() {
                _sortOrder = !_sortOrder;
                _sortIcon = _sortOrder
                    ? const Icon(Icons.north)
                    : const Icon(Icons.south);
                if (_sortOrder) {
                  _shownList.sort((a, b) => a.distance.compareTo(b.distance));
                } else {
                  _shownList.sort((a, b) => b.distance.compareTo(a.distance));
                }
              });
            }),
        Column(
          children: [
            Slider(
              activeColor: Colors.orange,
              value: _userRadius,
              max: Radar.maxDistance,
              divisions: 10,
              label: _userRadius.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _userRadius = value;
                  _shownList = applyFilter(_completeList);
                });
              },
            ),
            Text('Search radius: ${_userRadius.round().toString()} km'),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt_rounded),
          onPressed: () async {
            _shownList = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        StatefulBuilder(builder: (context, setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 16,
                            child: SizedBox(
                              height: 500,
                              child: ListView.builder(
                                  itemCount: widget.options.length + 1,
                                  itemBuilder: (context, int index) {
                                    if (index == 0) {
                                      //Header of List
                                      return ListTile(
                                          title: const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('Categories')),
                                          trailing: TextButton(
                                            child: const Text(
                                              'apply',
                                              style: TextStyle(
                                                  color: Colors.orange),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, _shownList);
                                            },
                                          ));
                                    }
                                    index -= 1;
                                    String option = widget.options[index];
                                    return CheckboxListTile(
                                      title: Text(option),
                                      checkColor: Colors.black,
                                      activeColor: Colors.orange,
                                      onChanged: (bool? _selected) {
                                        setState(() {
                                          if (!_interests.contains(option)) {
                                            _interests.add(option);
                                          } else {
                                            _interests.remove(option);
                                          }
                                          _shownList =
                                              applyFilter(_completeList);
                                        });
                                      },
                                      value: _interests.contains(option),
                                    );
                                  }),
                            ),
                          );
                        })));
            setState(() {});
            return;
          },
        ),
      ]),
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
                String error = '';
                if (_completeList.isEmpty) {
                  error = 'Nothing nearby';
                } else if (_shownList.isEmpty) {
                  error = 'Try changing your search settings';
                }
                if (!_serviceEnabled) {
                  error = 'Location service is disabled';
                } else if (_permission == LocationPermission.denied ||
                    _permission == LocationPermission.deniedForever) {
                  error = 'Location service has no permission';
                }
                if (error.isNotEmpty) {
                  return Expanded(
                      child: Center(
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.error_outline_rounded, size: 18),
                      Text(error),
                    ],
                  )));
                }

                _shownList = _shownList
                    .where((element) => element.distance < _userRadius)
                    .toList();

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
                          onRefresh: _refreshList)),
                );
            }
          })
    ]);
  }
}
