import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Impressum extends StatefulWidget {
  const Impressum({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Impressum();
}

class _Impressum extends State<Impressum> {
  String? data;

  void _loadData() async {
    final _loadedData = await rootBundle.loadString('assets/impressum.txt');
    setState(() {
      data = _loadedData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.00, vertical: 20.00),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Icon(
                  Icons.wrap_text,
                  color: Colors.white,
                  size: 180.00,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5.00, 25.00, 5.00, 0.00),
                  child: Text(data ?? '<error> please contact an admin', style: const TextStyle(color: Colors.white, fontSize: 20.00),))
            ],
          ),
        ),
      ),
    );
  }


}