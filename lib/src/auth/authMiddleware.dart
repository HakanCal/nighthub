import 'package:flutter/material.dart';

import '../homepage.dart';
import '../widgets.dart';
import './forms/index.dart';

enum AuthenticationState {
  loggedOut,
  emailNotRegistered,
  forgotPassword,
  registerUser,
  loggedIn,
}

class AuthMiddleware extends StatefulWidget {
  const AuthMiddleware({
    required this.authState,
    required this.email,
    required this.forgotPassword,
    required this.setAuthStateToRegisterUser,
    //required this.setAuthStateToRegisterBusiness,
    required this.sendNewPassword,
    required this.setAuthStateToLoggedOut,
    required this.signIn,
    required this.cancelRegistration,
    required this.registerUserAccount,
    required this.logOut,
  });

  final AuthenticationState authState;
  final String? email;
  final void Function() forgotPassword;
  final void Function() setAuthStateToRegisterUser;
  //final void Function() setAuthStateToRegisterBusiness;
  final void Function(
      String email,
      void Function(Exception e) error,
      ) sendNewPassword;
  final void Function() setAuthStateToLoggedOut;
  final void Function(
      String email,
      String password,
      void Function() navigator,
      void Function(Exception e) error,
      ) signIn;
  final void Function() cancelRegistration;
  final void Function(
      String username,
      String email,
      String password,
      void Function(Exception e) error,
      ) registerUserAccount;
  final void Function() logOut;

  @override
  _AuthMiddleware createState() => _AuthMiddleware();
}

class _AuthMiddleware extends State<AuthMiddleware> {
  @override
  Widget build(BuildContext context) {
    switch (widget.authState) {
     case AuthenticationState.forgotPassword:
        return ForgotPasswordForm(
          email: widget.email,
          sendNewPassword: (email) => widget.sendNewPassword(
            email, (e) => _showErrorDialog(context, 'Email could not be sent', e)
          ),
          setAuthStateToLoggedOut: () => widget.setAuthStateToLoggedOut(),
        );
      case AuthenticationState.loggedOut:
        return LoginForm(
          email: widget.email,
          login: (email, password, navigator) {
            widget.signIn(email, password, () => navigator(), (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
          forgotPassword: () => widget.forgotPassword(),
          setAuthStateToRegisterUser: () => widget.setAuthStateToRegisterUser(),
          //setAuthStateToRegisterBusiness: () => widget.setAuthStateToRegisterBusiness(),
        );
      case AuthenticationState.registerUser:
        return UserRegisterForm(
          email: widget.email,
          cancel: () {
            widget.cancelRegistration();
          },
          registerUserAccount: (username, email, password) {
            widget.registerUserAccount(
                username,
                email,
                password,
                (e) => _showErrorDialog(context, 'Failed to create account', e));
          },
        );
      case AuthenticationState.loggedIn:
        return const HomePage();
          /*children: [
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
        );*/
      default:
        return Row(
          children: const [
            Text("Internal error, something went wrong"),
          ],
        );
    }
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showGeneralDialog(
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              actionsPadding: const EdgeInsets.only(top: 0, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20)
              ),
              title: Text(
                title,
                style: const TextStyle(fontSize: 24),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      '${(e as dynamic).message}',
                      style: const TextStyle(fontSize: 16),
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
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {throw Exception;}
    );
  }
}