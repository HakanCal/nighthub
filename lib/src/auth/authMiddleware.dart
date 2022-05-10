import 'dart:io';
import 'package:flutter/material.dart';

import '../homepage.dart';
import '../widgets.dart';
import './forms/index.dart';

enum AuthenticationState {
  loggedOut,
  emailNotRegistered,
  forgotPassword,
  registerUser,
  registerBusiness,
  loggedIn,
}

class AuthMiddleware extends StatefulWidget {
  const AuthMiddleware({
    required this.authState,
    required this.email,
    required this.forgotPassword,
    required this.setAuthStateToRegisterUser,
    required this.setAuthStateToRegisterBusiness,
    required this.sendNewPassword,
    required this.setAuthStateToLoggedOut,
    required this.signIn,
    required this.cancelRegistration,
    required this.registerUserAccount,
    required this.registerBusinessAccount,
    required this.logOut,
  });

  final AuthenticationState authState;
  final String? email;
  final void Function() forgotPassword;
  final void Function() setAuthStateToRegisterUser;
  final void Function() setAuthStateToRegisterBusiness;
  final void Function(
    String email,
    void Function() toggleLoader,
    void Function(Exception e) error,
  ) sendNewPassword;
  final void Function() setAuthStateToLoggedOut;
  final void Function(
    String email,
    String password,
    void Function() navigator,
    void Function() toggleLoader,
    void Function(Exception e) error,
  ) signIn;
  final void Function() cancelRegistration;
  final void Function(
    String username,
    String email,
    String password,
    File? profilePicture,
    List<String> interests,
    void Function() toggleLoader,
    void Function(Exception e) error,
  ) registerUserAccount;
  final void Function(
    String entityName,
    String email,
    String password,
    String street,
    String postcode,
    String country,
    File? profilePicture,
    List<String> interests,
    void Function() toggleLoader,
    void Function(Exception e) error,
  ) registerBusinessAccount;
  final void Function() logOut;

  @override
  _AuthMiddleware createState() => _AuthMiddleware();
}

class _AuthMiddleware extends State<AuthMiddleware> {
  bool isLoading = false;

  /// Show loading spinner when communicating with Firebase
  void toggleLoader() async {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.authState) {
      case AuthenticationState.forgotPassword:
        return ForgotPasswordForm(
            email: widget.email,
            sendNewPassword: (email, toggleLoader) => widget.sendNewPassword(
                email,
                () => toggleLoader(),
                (e) => _showErrorDialog(context, 'Email could not be sent', e)),
            setAuthStateToLoggedOut: () => widget.setAuthStateToLoggedOut(),
            isLoading: isLoading,
            toggleLoader: () => toggleLoader());
      case AuthenticationState.loggedOut:
        return LoginForm(
            email: widget.email,
            login: (email, password, navigator, toggleLoader) {
              widget.signIn(
                  email,
                  password,
                  () => navigator(),
                  () => toggleLoader(),
                  (e) => _showErrorDialog(context, 'Failed to sign in', e));
            },
            forgotPassword: () => widget.forgotPassword(),
            setAuthStateToRegisterUser: () =>
                widget.setAuthStateToRegisterUser(),
            setAuthStateToRegisterBusiness: () =>
                widget.setAuthStateToRegisterBusiness(),
            isLoading: isLoading,
            toggleLoader: () => toggleLoader());
      case AuthenticationState.registerUser:
        return UserRegisterForm(
            email: widget.email,
            cancel: () {
              widget.cancelRegistration();
            },
            registerUserAccount: (username, email, password, profilePicture,
                interests, toggleLoader) {
              widget.registerUserAccount(
                  username,
                  email,
                  password,
                  profilePicture,
                  interests,
                  () => toggleLoader(),
                  (e) =>
                      _showErrorDialog(context, 'Failed to create account', e));
            },
            isLoading: isLoading,
            toggleLoader: () => toggleLoader());
      case AuthenticationState.registerBusiness:
        return BusinessRegisterForm(
            email: widget.email,
            cancel: () {
              widget.cancelRegistration();
            },
            registerBusinessAccount: (
              entityName,
              email,
              password,
              street,
              postcode,
              country,
              profilePicture,
              interests,
              toggleLoader,
            ) {
              widget.registerBusinessAccount(
                  entityName,
                  email,
                  password,
                  street,
                  postcode,
                  country,
                  profilePicture,
                  interests,
                  () => toggleLoader(),
                  (e) =>
                      _showErrorDialog(context, 'Failed to create account', e));
            },
            isLoading: isLoading,
            toggleLoader: () => toggleLoader());
      case AuthenticationState.loggedIn:
        return const HomePage();
      default:
        return Row(
          children: const [
            Text('Internal error, something went wrong'),
          ],
        );
    }
  }

  /// Show error modal with the default validation messages from Firebase
  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, errorDialogWidget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                actionsPadding: const EdgeInsets.only(top: 0, right: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
        pageBuilder: (context, animation1, animation2) {
          throw Exception;
        });
  }
}
