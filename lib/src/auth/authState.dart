import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocode/geocode.dart';
import 'package:dart_geohash/dart_geohash.dart';

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
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        if (kDebugMode) {
          print("User has signed in");
        }
        AuthenticationState.loggedIn;
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
      void Function() toggleLoader,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    toggleLoader();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail( email: email)
          .then((value) => toggleLoader());
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
      toggleLoader();
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
      void Function() toggleLoader,
      void Function(FirebaseAuthException e) errorCallback,
    ) async {
      toggleLoader();
      try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          ).then((value) {
            navigator();
          });
      } on FirebaseAuthException catch (e) {
        errorCallback(e);
        toggleLoader();
      }
    }

  /// Navigates back to login page
  void setAuthStateToRegisterUser() {
    _authState = AuthenticationState.registerUser;
    notifyListeners();
  }

  /// Navigates back to login page
  void setAuthStateToRegisterBusiness() {
    _authState = AuthenticationState.registerBusiness;
    notifyListeners();
  }

  ///  Registration process was interrupted
  void cancelRegistration() {
    _authState = AuthenticationState.loggedOut;
    notifyListeners();
  }

  /// Registration is finished and user account created
  Future<void> registerUserAccount(
      String username,
      String email,
      String password,
      File? profilePicture,
      List<String> interests,
      void Function() toggleLoader,
      void Function(FirebaseAuthException e) errorCallback
    ) async {
      toggleLoader();
      try {
        String? imageName = profilePicture?.path.split('/').last;
        if (imageName != null) {
          uploadProfilePicture(profilePicture!, imageName);
        }

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
            'profile_picture': imageName,
            'interests': interests,
            'business': false
           })
        );

      _authState = AuthenticationState.loggedOut;
      notifyListeners();
      toggleLoader();
      } on FirebaseAuthException catch (e) {
      errorCallback(e);
      toggleLoader();
    }
  }
  /// Registration is finished and business account created
  Future<void> registerBusinessAccount(
      String entityName,
      String email,
      String password,
      String street,
      String postcode,
      String country,
      File? profilePicture,
      List<String> interests,
      void Function() toggleLoader,
      void Function(FirebaseAuthException e) errorCallback
    ) async {
    toggleLoader();
    try {
        String? imageName = profilePicture?.path.split('/').last;
        if (imageName != null) {
          uploadProfilePicture(profilePicture!, imageName);
        }

        String address = '$street , $postcode, $country';

        var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password);

        var point = await createGeoPoint(address);

        await credential.user!.updateDisplayName(entityName)
          .then((value) => FirebaseFirestore.instance
          .collection('entity_accounts')
          .add(<String, dynamic>{
            'entityName': FirebaseAuth.instance.currentUser!.displayName,
            'email': FirebaseAuth.instance.currentUser!.email,
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'profilePicture': profilePicture?.path,
            'interests': interests,
            'business': true,
            'address': address,
            'point': point
          })
        );
        _authState = AuthenticationState.loggedOut;
        notifyListeners();
        toggleLoader();
    } on FirebaseAuthException catch (e) {
        errorCallback(e);
        toggleLoader();
    }
  }

  /// User logs out
  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  /// Saves picture in Firebase Storage
  void uploadProfilePicture(File profilePicture, String imageName) {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('/$imageName');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': profilePicture.path});

    firebase_storage.UploadTask uploadTask = ref.putFile(File(profilePicture.path), metadata);
    uploadTask.whenComplete(() {
      if (kDebugMode) {
        print('Photo was uploaded to storage');
      }
    });
  }

  /// Creates geohash, longitude and latitude from address
  Future<Object> createGeoPoint(String address) async {
    var point = {};
    GeoCode geoCode = GeoCode();

    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(address: address);
      GeoHash geoHash = GeoHash.fromDecimalDegrees(coordinates.longitude!, coordinates.latitude!);
      point = {
        'geohash': geoHash.geohash,
        'geopoint': GeoPoint(coordinates.latitude!, coordinates.longitude!)
      };
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return point;
  }
}