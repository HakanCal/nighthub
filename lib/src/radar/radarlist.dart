import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nighthub/src/radar/radaritem.dart';


class RadarList extends StatefulWidget{
  const RadarList({this.sortMethod = 'distance' ,Key? key}) : super(key: key);
  final String sortMethod;

  @override
  State<StatefulWidget> createState() => _RadarList();
}



class _RadarList extends State<RadarList>{
  Geoflutterfire geo = Geoflutterfire();
  Position _userPos = const Position(latitude: 48.783333, longitude: 9.183333, accuracy: 1.0, altitude: 1, speedAccuracy: 1.0, timestamp: null, speed: 1.0, heading: 1.0);
  List<RadarItem> _radaritems = [];
  sortBy(){
      switch(widget.sortMethod){
        case 'distance':
          _radaritems.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'rating':
          _radaritems.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
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
  static Image logo = Image.network('https://logos-download.com/wp-content/uploads/2016/05/Coffeeshop_Company_logo_logotype.png');

  Future<void> _getItems() async {
    print('getting new items...');
    await Firebase.initializeApp();
    _userPos = await _determinePosition();
    // Geo query nearby items 25km
    GeoFirePoint center = geo.point(latitude: _userPos.latitude, longitude: _userPos.longitude);
    Query<Map<String,dynamic>> collectionRef = FirebaseFirestore.instance.collection('entity_accounts');
    Stream<List<DistanceDocSnapshot>> stream = geo.collection(collectionRef: collectionRef)
        .withinWithDistance(center: center, radius: 25, field: 'point');

    _radaritems = [];
    stream.listen((List<DistanceDocSnapshot> shopDocuments) => {
       shopDocuments.forEach((shop) {
         setState(() {
              _radaritems.add(
                  RadarItem(
                    name: shop.documentSnapshot['entityName'],
                    logo: logo,
                    address: shop.documentSnapshot['address'],
                    distance: shop.kmDistance,
                    categories: shop.documentSnapshot['interests'],
                    rating: 1
                  )
              );
          });
      })

    });
    sortBy();
    //setState(() {_radaritems = _radaritems;});
  }
  @override
  void initState() {
    _getItems().then((value) {
      print('trying to sort');
      sortBy();
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    print(_radaritems);
    return RefreshIndicator(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              RadarItem radaritem = _radaritems[index];
              return Center(child: radaritem);
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _radaritems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            }
        ),
        onRefresh: _getItems // refreshes list content on swiping down
    );
  }
}
