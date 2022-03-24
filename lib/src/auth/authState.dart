import 'dart:async';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:provider/provider.dart';

import './authMiddleware.dart';
class AuthState extends ChangeNotifier {
  AuthState() {
    init();
  }

  /// Assuming the user is logged-out the first time
  AuthenticationState _authState = AuthenticationState.loggedOut;
  AuthenticationState get authState => _authState;

  /// init() function to check whether user is logged-in or -out
  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _authState = AuthenticationState.loggedIn;
        /*_reviewSubscription = FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _reviewMessages = [];
          for (final document in snapshot.docs) {
            _reviewMessages.add(
              ReviewMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });*/
      } else {
        _authState = AuthenticationState.loggedOut;
        //_reviewMessages = [];
        //_reviewSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  /*StreamSubscription<QuerySnapshot>? _reviewSubscription;
  List<ReviewMessage> _reviewMessages = [];
  List<ReviewMessage> get reviewMessages => _reviewMessages;*/

  String? _email;
  String? get email => _email;

  /// Auth state changes and navigates to ForgotPassword page
  void forgotPassword() {
    _authState = AuthenticationState.forgotPassword;
    notifyListeners();
  }

  /// Sends email withe instructions to change password
  Future<void> sendNewPassword(
      String email,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail( email: email);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  /// Navigates back to login page
  void setAuthStateToLoggedOut() {
    _authState = AuthenticationState.loggedOut;
    notifyListeners();
  }

  /// Sign in by entering email and password
  Future<void> signIn(
      String email,
      String password,
      void Function() navigator,
      void Function(FirebaseAuthException e) errorCallback,
    ) async {
      try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          _authState = AuthenticationState.loggedIn;
          navigator();
      } on FirebaseAuthException catch (e) {
        errorCallback(e);
      }
    }

  /// Navigates back to login page
  void setAuthStateToRegisterUser() {
    _authState = AuthenticationState.registerUser;
    notifyListeners();
  }

  ///  Registration process was interrupted
  void cancelRegistration() {
    _authState = AuthenticationState.loggedOut;
    notifyListeners();
  }

  /// Registration is finished and account created
  Future<void> registerUserAccount(
      String username,
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password);
      await credential.user!.updateDisplayName(username)
        .then((value) => FirebaseFirestore.instance
          .collection('user_accounts')
          .add(<String, dynamic>{
            'username': FirebaseAuth.instance.currentUser!.displayName,
            'email': FirebaseAuth.instance.currentUser!.email,
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
           })
        );
      _authState = AuthenticationState.loggedOut;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  /// User logs out
  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  /*Future<DocumentReference> submitReview(String message) {
    if (_authState != AuthenticationState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('reviews')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }*/
}