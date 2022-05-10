import 'package:flutter/material.dart';
import 'package:nighthub/src/auth/authFlowScreens.dart';
import 'package:provider/provider.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.amber),
        textTheme:
            const TextTheme(bodyText1: TextStyle(), bodyText2: TextStyle())
                .apply(bodyColor: Colors.white, displayColor: Colors.white),
        fontFamily: 'anybody',
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const AuthFlowScreens(),
        '/home': (BuildContext context) => const HomePage(),
      },
    );
  }
}
