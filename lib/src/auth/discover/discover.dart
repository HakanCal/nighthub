
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Discover();
}

class _Discover extends State<Discover> {

//  List<Object> partyEntities = new List<Object>;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF262626),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Text('HI'),
    );
  }

}