import 'package:flutter/material.dart';
import 'package:nighthub/src/radar/radaritem.dart';

class RadarList extends StatefulWidget{
  const RadarList({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RadarList();
}

class _RadarList extends State<RadarList>{

  //final List<RadarItem> items;
  static List<Widget> radaritems = [
    const Text('Item 1'),
    const Text('Item 2'),
    const Text('Item 3'),const Text('Item 3'),const Text('Item 3'),const Text('Item 3'),const Text('Item 3'),
    Container(
      height: 120,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.deepOrange, width: 10),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(children: [
          Expanded(child: FittedBox(fit: BoxFit.contain,child:Image.network('https://logos-download.com/wp-content/uploads/2016/05/Coffeeshop_Company_logo_logotype.png'))),
          Expanded(child: Column(children: [Text('Shop Name Example', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),SizedBox(height: 10),Text('kat')])),
          Expanded(child: Column(children: [Text('Rating: 4/5'),SizedBox(height: 10),Text('Distance: 20km')]))
        ])
    )
  ];
  //final Position position;
  //TODO get shops near me
  // loads in businesses near me
  Future<void> getItems() async {
    print('getting new items...');
    radaritems.add(const Text('new Item'));
    setState(() {});
    // request new shops from db
    // shops.forEach((shop) => {items.add(RadarItem(name: shop.name, logo: shop.logo ... ))})
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Widget radaritem = radaritems[index];
              return Center(child: radaritem);
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true, //TODO make it scrollable
            itemCount: radaritems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            }
        ),
        onRefresh: getItems // refreshes list content on swiping down
    );
  }
}
