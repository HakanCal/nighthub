import 'package:flutter/material.dart';
import 'package:nighthub/src/radar/radarlist.dart';

class Radar extends StatefulWidget {
  const Radar({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Radar();
}

class _Radar extends State<Radar> {
  String _sortMethod = 'distance';

  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          // Menu for changing List
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                  children:[
                    const Icon(Icons.list_rounded,color: Colors.orange ),
                    TextButton(
                        child: Text('Sort by ${_sortMethod}'),
                        onPressed: () => setState(() {
                          _sortMethod = _sortMethod == 'distance' ? 'rating' : 'distance';
                        })
                    )
                  ]
              )
          ),
          // List with Shops
          Expanded(child: Scrollbar(
            isAlwaysShown: false,
            //always show scrollbar
            thickness: 10,
            //width of scrollbar
            radius: const Radius.circular(20),
            //corner radius of scrollbar
            scrollbarOrientation: ScrollbarOrientation.left,
            child: RadarList(sortMethod: _sortMethod)
          ))
        ]
    );
  }

}
