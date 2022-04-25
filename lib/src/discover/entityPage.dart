
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../auth/formFields/customChipList.dart';

class EntityPage extends StatefulWidget {

  const EntityPage({
    Key? key,
    required this.entityName,
    required this.address,
    required this.distance,
    required this.tags,
    required this.about

  }) : super(key: key);

  final String entityName;
  final String address;
  final double distance;
  final List<String> tags;
  final String about;

  @override
  State<StatefulWidget> createState() => _EntityPage();
}

class _EntityPage extends State<EntityPage> {

  Widget separationLine() => Container(
    height: 2,
    width: MediaQuery.of(context).size.width,
    color: const Color(0xFF2F2F2F),
  );

  @override
  Widget build(BuildContext context) {

    ScrollController scroller = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(''),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        controller: scroller,
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
            child: Column(
              children: [
                pictureSwiper(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                entityName(),
                const Padding(padding: EdgeInsets.only(top: 5.00)),
                entityAddress(),
                const Padding(padding: EdgeInsets.only(top: 5.00)),
                entityDistance(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                separationLine(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                CustomChipList(
                  values: widget.tags,
                  chipBuilder: (String value) {
                    return Chip(label: Text(value));
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                separationLine(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                Text(
                  widget.about,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.00
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 50.00)),
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }

  final List<File> images = [File('assets/dance-club.gif'), File('assets/nighthub.png'), File('assets/dummy-profile-pic.jpg')];

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
                image: AssetImage(images[index].path),
              ),
            ),
            //child: Image.asset(File(images[index]).path, fit: BoxFit.cover)
        );
      },
      index: 0,
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
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
      widget.entityName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 33.00,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget entityAddress() => Row(
    children: [
      const Icon(Icons.location_on_outlined, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10.00)),
      Flexible(
        child: Text(
          widget.address,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.00,
          ),
        ),
      )
    ],
  );

  Widget entityDistance() => Row(
    children: [
      const Icon(Icons.directions_walk, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10.00)),
      Flexible(
        child: Text(
          '${widget.distance} km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.00,
          ),
        ),
      )
    ],
  );

}