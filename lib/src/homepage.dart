import 'package:flutter/material.dart';
import 'package:nighthub/src/widgets.dart';

import 'navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home Page'),
      ),
      body: const Center(
          child: NavBar(),
        ),
      );
  }
}