import 'package:flutter/material.dart';

import '../widgets.dart';
import './forms/index.dart';

enum AuthenticationState {
  loggedOut,
  emailAddress,
  forgotPassword,
  register,
  loggedIn,
}

class AuthMiddleware extends StatelessWidget {
  const AuthMiddleware({
    required this.authState,
    required this.email,
    required this.forgotPassword,
    required this.sendNewPassword,
    required this.loginWithNewPassword,
    //required this.startLogin,
    //required this.verifyEmail,
    required this.signIn,
    required this.cancelRegistration,
    required this.registerAccount,
    required this.logOut,
  });

  final AuthenticationState authState;
  final String? email;
  //final void Function() startLogin;
  /*final void Function(
      String email,
      void Function(Exception e) error,
      ) verifyEmail;*/
  final void Function() forgotPassword;
  final void Function(
      String email,
      void Function(Exception e) error,
      ) sendNewPassword;
  final void Function() loginWithNewPassword;
  final void Function(
      String email,
      String password,
      void Function(Exception e) error,
      ) signIn;
  final void Function() cancelRegistration;
  final void Function(
      String email,
      String username,
      String password,
      void Function(Exception e) error,
      ) registerAccount;
  final void Function() logOut;

  @override
  Widget build(BuildContext context) {
    switch (authState) {
      /*case AuthenticationState.loggedOut: //TODO: add screen for the different cases?
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: StyledButton(
                onPressed: () {
                  signIn();
                },
                child: const Text('SIGN IN'),
              ),
            ),
          ],
        );*/
      case AuthenticationState.forgotPassword:
        return ForgotPasswordForm(
          email: email,
          sendNewPassword: (email) => sendNewPassword(
            email, (e) => _showErrorDialog(context, 'Email could not be sent', e)
          ),
          loginWithNewPassword: () => loginWithNewPassword(),
        );
      case AuthenticationState.loggedOut:
        return LoginForm(
          email: email,
          login: (email, password) {
            signIn(email, password, (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
          forgotPassword: () => forgotPassword(),
        );
      case AuthenticationState.register:
        return RegisterForm(
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          registerAccount: (email, username, password) {
            registerAccount(
                email,
                username,
                password,
                (e) => _showErrorDialog(context, 'Failed to create account', e));
          },
        );
      case AuthenticationState.loggedIn:
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: StyledButton(
                onPressed: () {
                  logOut();
                },
                child: const Text('LOGOUT'),
              ),
            ),
          ],
        );
      default:
        return Row(
          children: const [
            Text("Internal error, something went wrong"),
          ],
        );
    }
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}