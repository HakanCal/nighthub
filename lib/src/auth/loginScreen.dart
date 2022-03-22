import 'package:flutter/material.dart';
//import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import './authMiddleware.dart';
import './authState.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Welcome!'),
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
          /*const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header('What needs to be done'),
          const Paragraph('Setup Firebase to the app'),
          Consumer<AuthState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.authState == AuthenticationState.loggedIn) ...[
                  const Header('Review'),
                  Review(
                    addMessage: (message) =>
                        appState.submitReview(message),
                  ),
                ],
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}