import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _About();
}

class _About extends State<About> {
  String? data;

  void _loadData() async {
    final _loadedData = await rootBundle.loadString('assets/about.txt');
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset('assets/nighthub.png', width: 150, height: 150),
              ),
              Text(data ?? '<error> please contact an admin', style: const TextStyle(color: Colors.white, fontSize: 20.00),)
            ],
          ),
        ),
      ),
    );
  }

}