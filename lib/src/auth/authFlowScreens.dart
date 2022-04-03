import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './authMiddleware.dart';
import './authState.dart';

class AuthFlowScreens extends StatelessWidget {
  const AuthFlowScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(1, 24, 26, 32),
        body: ListView(
          controller: ScrollController(),
          addAutomaticKeepAlives: true,
          padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Image.asset('assets/nighthub.png', width: 50, height: 200, fit: BoxFit.contain),
            ),
            Consumer<AuthState>(
              builder: (context, appState, _) => AuthMiddleware(
                email: appState.email,
                authState: appState.authState,
                forgotPassword: appState.forgotPassword,
                setAuthStateToRegisterUser: appState.setAuthStateToRegisterUser,
                setAuthStateToRegisterBusiness: appState.setAuthStateToRegisterBusiness,
                sendNewPassword: appState.sendNewPassword,
                setAuthStateToLoggedOut: appState.setAuthStateToLoggedOut,
                signIn: appState.signIn,
                cancelRegistration: appState.cancelRegistration,
                registerUserAccount: appState.registerUserAccount,
                registerBusinessAccount: appState.registerBusinessAccount,
                logOut: appState.logOut,
              ),
            ),
            /*
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
      ),
    );
  }
}