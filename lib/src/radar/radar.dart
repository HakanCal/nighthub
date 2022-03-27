import 'package:flutter/material.dart';
import 'package:nighthub/src/radar/radarlist.dart';

class Radar extends StatefulWidget {
  const Radar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Radar();
}

class _Radar extends State<Radar> {

  String sortMethod = 'distance';
//TODO better ui
  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          // Menu for changing List
          Row(children:[TextButton(child: Text('Sort by $sortMethod'), onPressed: () => {setState((){sortMethod = 'rating';})})]),
          // Show a scrollabe List of businesses near
          const Scrollbar(
            isAlwaysShown: true,
            //always show scrollbar
            thickness: 10,
            //width of scrollbar
            radius: Radius.circular(20),
            //corner radius of scrollbar
            scrollbarOrientation: ScrollbarOrientation.left,
            child: RadarList()
          )
        ]
    );
  }
}
