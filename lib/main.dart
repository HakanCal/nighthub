import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nighthub/src/auth/authFlowScreens.dart';
import 'package:nighthub/src/auth/authState.dart';
import 'package:nighthub/src/homepage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthState(),
      child: const NightHub(),
    ),
  );
}

class NightHub extends StatelessWidget {
  const NightHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome Screen',
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => const AuthFlowScreens(),
          '/home': (BuildContext context) => const HomePage(),
        },
    );
  }
}

