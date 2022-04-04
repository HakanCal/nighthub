import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Impressum extends StatefulWidget {
  const Impressum({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _Impressum();

}

class _Impressum extends State<Impressum> {

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