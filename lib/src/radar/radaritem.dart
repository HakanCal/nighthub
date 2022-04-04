import 'package:flutter/material.dart';

// Layout of one list item
class RadarItem extends StatelessWidget {
  const RadarItem(
      {required this.name,
      required this.logo,
      required this.address,
      required this.distance,
      required this.categories,
      required this.rating,
      Key? key})
      : super(key: key);

  final String name;
  final Image logo;
  final String address;
  final double distance;
  final List<dynamic> categories;
  final double rating;

  //final int shopID
  //TODO route widget to shop page
  void goToBusiness(int shopID) {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {print('shop')}, //go to shop page
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 120,
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.deepOrange, width: 5),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Expanded(
                  child: FittedBox(fit: BoxFit.contain, child: logo), flex: 1),
              Expanded(
                  child: _RadarItemBody(name: name, categories: categories),
                  flex: 1),
              Expanded(
                  child: _RadarItemTrailer(rating: rating, distance: distance),
                  flex: 1)
            ], crossAxisAlignment: CrossAxisAlignment.stretch)));
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
    return Column(children: [
      Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          child: Text(threeCategories(),
              style: const TextStyle(color: Colors.white, fontSize: 15)))
    ],
    crossAxisAlignment: CrossAxisAlignment.stretch);
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
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.star, color: Colors.yellow),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 15))
            ])),
        const SizedBox(height: 15),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${distance.toStringAsFixed(2)} km',
                style: const TextStyle(color: Colors.white, fontSize: 15)))
      ]
    );
  }
}