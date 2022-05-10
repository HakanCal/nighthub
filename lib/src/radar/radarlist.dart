import 'package:flutter/material.dart';
import './radarItem.dart';

class RadarList extends StatelessWidget {
  final List<RadarItem> radarItems;

  const RadarList({required this.radarItems, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return radarItems[index];
        },
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: radarItems.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        });
  }
}
