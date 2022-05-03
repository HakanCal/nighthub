import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../auth/formFields/customChipList.dart';
import 'entity.dart';

class EntityPage extends StatefulWidget {
  const EntityPage({
    Key? key,
    required this.entity
  }) : super(key: key);

  final Entity entity;

  @override
  State<StatefulWidget> createState() => _EntityPage();
}

class _EntityPage extends State<EntityPage> {

  final DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref();
  List<NetworkImage> images = [];

  bool loading = true;


  @override
  void initState() {
    super.initState();
    loadCarouselPics();
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> loadCarouselPics() async {
    realtimeDatabase.child('user_accounts/').orderByKey().limitToFirst(30).get().then((snapshot) {
      Map<dynamic, dynamic> users = snapshot.value as Map;
      users.forEach((key, value) async {
        if(value['business'] == true) {
          final businessPictures = await firebase_storage.FirebaseStorage
              .instance
              .ref()
              .child('business_pictures/${value['userId']}').listAll();
          if (businessPictures.items.isNotEmpty) {

            for (var element in businessPictures.items) {
              await element.getDownloadURL().then((value) {
                setState(() {
                  images.add(NetworkImage(value.toString()));
                });
              });
            }
          }
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return loading == true ? Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/nighthub.png', width: 200, height: 200, fit: BoxFit.contain),
            const SpinKitFadingCircle(
              color: Colors.orange,
              size: 60,
            ) ,
          ],
        )) : Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: widget.entity.isBusiness ? AppBar(
        backgroundColor: Colors.black,
        title: const Text(''),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ) : null,
      body: ListView(
        controller: ScrollController(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFF262626),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
              child: Column(
                children: [
                  pictureSwiper(),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  entityName(),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  entityAddress(),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  entityDistance(),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  separationLine(),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  CustomChipList(
                    values: widget.entity.tags,
                    chipBuilder: (String value) {
                      return Chip(label: Text(value));
                    },
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  separationLine(),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  Text(
                    widget.entity.about,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 50)),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget pictureSwiper() => Container(
    width: MediaQuery.of(context).size.height * 0.7,
    height: MediaQuery.of(context).size.width * 1,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    child: Swiper(
      itemBuilder: (BuildContext context, int index) {
        return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: images[index]
              ),
            ),
            //child: Image.asset(File(images[index]).path, fit: BoxFit.cover)
        );
      },
      index: 0,
      scrollDirection: Axis.horizontal,
      itemCount: images.length, //widget.entity.images.length,
      autoplay: false,
      pagination: const SwiperPagination(),
      control: const SwiperControl(
        color: Colors.transparent,
      ),
    ),
  );

  Widget entityName() => Container(
    alignment: Alignment.bottomLeft,
    child: Text(
      widget.entity.username,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 33,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget entityAddress() => Row(
    children: [
      const Icon(Icons.location_on_outlined, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10)),
      Flexible(
        child: Text(
          widget.entity.address,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      )
    ],
  );

  Widget entityDistance() => Row(
    children: [
      const Icon(Icons.directions_walk, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10)),
      Flexible(
        child: Text(
          '${widget.entity.distance} km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      )
    ],
  );

  Widget separationLine() => Container(
    height: 2,
    width: MediaQuery.of(context).size.width,
    color: const Color(0xFF2F2F2F),
  );

}