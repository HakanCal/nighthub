import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../discover/entity.dart';
import '../discover/entityPage.dart';

// Layout of one list item
class RadarItem extends StatelessWidget {
  RadarItem(
      {required this.userID,
      required this.name,
      required this.address,
      required this.logo,
      required this.distance, // distance in km
      required this.categories,
      required this.rating,
      Key? key})
      : super(key: key);

  final String userID;
  final String name;
  final String address;
  final String logo;
  final double distance;
  final List<dynamic> categories;
  final double rating;

  DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref();
  String primaryImageUrl = '';

  List<String> getUserInterests(List<dynamic> userData) {
    List<String> list = [];
    for (var elem in userData) {
      list.add(elem);
    }
    return list;
  }

  Future<Entity> getBusinessData() async {
    DatabaseEvent event =
        await realtimeDatabase.child('user_accounts/$userID/').once();
    final value = Map<String, dynamic>.from(event.snapshot.value as dynamic);
    final businessPictures = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('business_pictures/$userID}')
        .listAll();
    if (businessPictures.items.isNotEmpty) {
      await businessPictures.items.last.getDownloadURL().then((value) {
        primaryImageUrl = value.toString();
      });
    }
    return Entity(
        userId: value['userId'],
        isBusiness: false,
        username: value['username'],
        address: value['address'],
        distance: 1.6,
        tags: getUserInterests(value['interests']),
        about: value['about'],
        primaryImage: NetworkImage(primaryImageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async => {
              getBusinessData().then((ent) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EntityPage(entity: ent))))
            }, //go to shop page
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 150,
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Row(children: [
                Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 60,
                        backgroundImage: logo == ''
                            ? const AssetImage('assets/user_image.png')
                            : NetworkImage(logo) as ImageProvider,
                      ),
                    ),
                    flex: 1),
                Expanded(
                    child: _RadarItemBody(name: name, categories: categories),
                    flex: 2),
                Expanded(
                    child:
                        _RadarItemTrailer(rating: rating, distance: distance),
                    flex: 1)
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
            )));
  }
}

// Contains name, categories, address
class _RadarItemBody extends StatelessWidget {
  const _RadarItemBody({required this.name, required this.categories, Key? key})
      : super(key: key);
  final String name;
  final List<dynamic> categories;

  String threeCategories() {
    String cats = categories[0];
    for (int i = 1; i < 3; i++) {
      cats += ',' + categories[i];
    }
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              )),
          flex: 2,
        ),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: Text(threeCategories(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              )),
          flex: 1,
        )
      ]),
    );
  }
}

class _RadarItemTrailer extends StatelessWidget {
  const _RadarItemTrailer(
      {required this.distance, required this.rating, Key? key})
      : super(key: key);
  final double distance;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Expanded(
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.star, color: Colors.yellow),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 15))
            ]),
          ),
          flex: 2,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text('${distance.toStringAsFixed(2)} km',
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          flex: 1,
        )
      ]),
    );
  }
}
