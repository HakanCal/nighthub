import 'package:flutter/material.dart';
//import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import './authMiddleware.dart';
import './authState.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Forgot Password'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/img.png'),
          const SizedBox(height: 8),
          Consumer<AuthState>(
            builder: (context, appState, _) => AuthMiddleware(
              email: appState.email,
              authState: appState.authState,
              forgotPassword: appState.forgotPassword,
              sendNewPassword: appState.sendNewPassword,
              loginWithNewPassword: appState.loginWithNewPassword,
              //startLogin: appState.startLogin,
              //verifyEmail: appState.verifyEmail,
              signIn: appState.signIn,
              cancelRegistration: appState.cancelRegistration,
              registerAccount: appState.registerAccount,
              logOut: appState.logOut,
            ),
          ),
        ],
      ),
    );
  }
}