import 'package:flutter/material.dart';

/*
* navigator fehlt
* */

class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Form(
          child: Column(
            children: [
              TextFormField(
                obscureText: false,
                decoration: const InputDecoration(
                    icon: Icon(Icons.person, color: Colors.orange),
                    border: OutlineInputBorder(),
                    labelText: "Username"),
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                    icon: Icon(Icons.lock, color: Colors.orange),
                    border: OutlineInputBorder(),
                    labelText: "Password"),
              )
            ],
          ),
        )
    );
  }
}
