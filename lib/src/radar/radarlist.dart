import 'package:flutter/material.dart';
import 'package:nighthub/src/radar/radaritem.dart';

class RadarList extends StatelessWidget{
  final List<RadarItem> radarItems;
  const RadarList({required this.radarItems, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return
      ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          RadarItem radaritem = radarItems[index];
          return radaritem;
        },
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: radarItems.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        }
    );
  }
}