import 'package:flutter/cupertino.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Favorites();
}

class _Favorites extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('New feature coming soon...',
                style: TextStyle(fontSize: 25))
          ],
        )
        //TODO: Hakan Favoriten unter like bei User abgespeichert
        //TODO: Sortierbar nach Alphabet und Distance filterbar anzeigen
        //TODO: bei Klick --> Clubseite anzeigen
        );
  }
}
