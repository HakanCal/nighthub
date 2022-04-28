import 'dart:io';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage('') //TODO: widget.entity.images[index],
              ),
            ),
            //child: Image.asset(File(images[index]).path, fit: BoxFit.cover)
        );
      },
      index: 0,
      scrollDirection: Axis.horizontal,
      itemCount: 0, //widget.entity.images.length,
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