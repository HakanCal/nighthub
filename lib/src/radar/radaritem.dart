import 'package:flutter/material.dart';


// Layout of one list item
class RadarItem extends StatelessWidget{
  const RadarItem({
    required this.name,
    required this.logo,
    required this.address,
    required this.distance,
    required this.categories,
    required this.rating,
    Key? key
  }) : super(key: key);

  final String name;
  final Image logo;
  final String address;
  final double distance;
  final List<String> categories;
  final double rating;

  @override
  Widget build(BuildContext context){
    return Container(
        height: 120,
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.deepOrange, width: 10),
            borderRadius: BorderRadius.circular(20)
        ),
        child: Row(children: [
          Expanded(child: FittedBox(fit: BoxFit.contain,child:logo)),
          Expanded(child: Column(children: [Text(name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),SizedBox(height: 10),Text('kat')])),
          Expanded(child: Column(children: [Text('Rating: $rating'),SizedBox(height: 10),Text('$distance km')]))
        ])
    );
  }

}