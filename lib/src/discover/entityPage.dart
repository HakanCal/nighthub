
import 'package:flutter/material.dart';

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
                  style: TextStyle(
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

  //TODO: Image swiper
  Widget pictureSwiper() => ClipRRect(
    child: Container(
      width: MediaQuery.of(context).size.height * 0.7,
      height: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
        color: Color(0x8c8c8c8c),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/dance-club.gif'),
        ),
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