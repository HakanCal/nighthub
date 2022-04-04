import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nighthub/src/auth/authFlowScreens.dart';
import 'package:provider/provider.dart';

import 'package:nighthub/src/settings/settings.dart';
import 'package:nighthub/src/auth/authState.dart';

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
          //! CHANGED: BEFORE -> const AuthFlowScreens()
          '/': (BuildContext context) => const AuthFlowScreens(),
          '/home': (BuildContext context) => const HomePage(),
        },
    );
  }
}

