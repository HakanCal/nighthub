import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Description extends StatefulWidget {
  const Description({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _Description();

}

class _Description extends State<Description> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Text('#TODO'),
    );
  }

}