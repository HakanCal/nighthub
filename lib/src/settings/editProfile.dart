import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/authState.dart';
import '../auth/formFields/index.dart';
import 'package:nighthub/src/settings/settings.dart';
import '../dialogs/customFadingDialog.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({
    Key? key,
    required this.userData,
    required this.profilePicture
  }) : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  final userCredentials = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>(debugLabel: '_EditUserProfileFormState');
  final _usernameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final imagePicker = ImagePicker();
  final options = ['Nightclub','Dance','Club','Bar','Night Life','Live Music','Latin','Festival','Event','Drinks','Cafe','Rock','Jazz','Metal','EDM','Pop','Techno','Electro','Hip Hop','Rap','Punk'];

  String username = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.userData['username'];
    _emailController = TextEditingController(text: widget.userData['email']);
    _interests = getUserInterests(widget.userData['interests']);
    _profilePicture = widget.profilePicture;
    options.sort((a, b) { //sorting in ascending order
      return a.compareTo(b);
    });
   }

  bool isLoading = false;
  bool _isPasswordHidden = true;
  bool _isUpdateEmail = false;
  bool _isUpdatePassword = false;
  String errorMessage = '';

  /// Show loading spinner when communicating with Firebase
  void toggleLoader() async {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void onChangedInterest(String option) {
    setState(() {
      if (!_interests.contains(option)) {
        _interests.add(option);
      } else {
        _interests.remove(option);
      }
    });
  }

  /// Method for selecting a new profile picture
  Future selectOrTakePhoto(ImageSource imageSource) async {
    final pickedFile = await imagePicker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path);
      }
    });
  }

  /// Updates the user data if desired
  Future<void> updateUserAccount(
      BuildContext context,
      String username,
      String email,
      File? profilePicture,
      List<String> interests,
      Function() loader) async
  {
    toggleLoader();

    if (email.isNotEmpty && email != widget.userData['email']) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.userData['email'],
        password: _currentPasswordController.text,
      ).then((value) {
        userCredentials?.updateEmail(email)
            .then((value) {
          debugPrint('Email was updated');
        }).catchError((onError) {
          setState(() {
            errorMessage = 'Email empty or wrong format';
          });
        });
      });
    }

    if (_newPasswordController.text.isNotEmpty) {
      await userCredentials?.updatePassword(_newPasswordController.text)
          .then((value) {
        debugPrint('Password was updated');
      }).catchError((onError) {
        setState(() {
          errorMessage = 'Password should be at least 6 characters';
        });
      });
    }

    if (errorMessage.isNotEmpty) {
      toggleLoader();
      showCustomFadingDialog(
          context, errorMessage, Icons.error_outline, Colors.grey, Colors.red);
    } else {
      String? imageName = profilePicture?.path
          .split('/')
          .last;

      if (imageName != widget.userData['profile_picture']) {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage
            .instance
            .ref()
            .child('profile_pictures')
            .child('/${widget.userData['profile_picture']}');

        await ref.delete()
            .then((value) =>
            Provider.of<AuthState>(context, listen: false).uploadProfilePicture(
                profilePicture!, imageName!));
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref(
          'user_accounts/$userId/');

      realtimeDatabase.update({
        'username': username,
        'email': email,
        'profile_picture': imageName,
        'interests': interests
      });

      toggleLoader();
      Navigator.pop(context);
      showCustomFadingDialog(context, 'Profile updated successfully', Icons.check_circle_outlined, Colors.grey, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit profile'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
          controller: ScrollController(),
          addAutomaticKeepAlives: true,
          padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            Column(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        child: CustomImagePicker(
                          profilePicture: _profilePicture,
                          selectOrTakePhoto: selectOrTakePhoto,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.00),
                        child: CustomTextField(
                          hint: 'Enter username',
                          controller: _usernameController,
                          onSaved: (input) {
                            username = input!;
                          },
                          validator: (value) {
                            if(value!.isEmpty) {
                              return 'Please username cannot be empty';
                            }
                            return null;
                          },
                          iconWidget: IconButton(
                            icon: const Icon(Icons.account_circle_rounded),
                            color: Colors.blueGrey,
                            onPressed: () {},
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: CustomDropdownField(
                          values: _interests,
                          hintText: 'Change interests',
                          options: options,
                          validator: (value) {
                            if (_interests.length < 3) {
                              return 'Please select at least 3 interests';
                            }
                            return null;
                          },
                          onChanged: onChangedInterest,
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            children: [
                              const Text(
                                'Update Email',
                                style: TextStyle(color: Colors.orange, fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(_isUpdateEmail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                color: Colors.orange,
                                onPressed: () {
                                  setState(() {
                                    _isUpdateEmail = !_isUpdateEmail;
                                  });
                                },
                              )
                            ],
                          )
                      ),
                      Container(
                          child: _isUpdateEmail ?
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: CustomTextField(
                                    hint: 'New Email',
                                    controller: _emailController,
                                    onSaved: (input) {
                                      email = input!;
                                    },
                                    validator: (value) {
                                      if (_isUpdateEmail && value!.isEmpty) {
                                        return 'Please email cannot be empty';
                                      }
                                      return null;
                                    },
                                    iconWidget: IconButton(
                                      icon: const Icon(Icons.email),
                                      color: Colors.blueGrey,
                                      onPressed: () {},
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  child: CustomTextField(
                                    hint: 'Current password',
                                    isHidden: true,
                                    controller: _currentPasswordController,
                                    onSaved: (input) {
                                      email = input!;
                                    },
                                    validator: (value) {
                                      if (_isUpdateEmail && value!.isEmpty) {
                                        return 'Please password cannot be empty';
                                      }
                                      return null;
                                    },
                                    iconWidget: IconButton(
                                      icon: const Icon(Icons.password_outlined),
                                      color: Colors.blueGrey,
                                        onPressed: () {},
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                  ),
                                ),
                              ]
                          ) : null
                      ),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            children: [
                              const Text(
                                'Update Password',
                                style: TextStyle(color: Colors.orange, fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(_isUpdatePassword ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                color: Colors.orange,
                                onPressed: () {
                                  setState(() {
                                    _isUpdatePassword = !_isUpdatePassword;
                                  });
                                },
                              )
                            ],
                          )
                      ),
                      Container(
                          child: _isUpdatePassword ?
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: CustomTextField(
                                    hint: 'New password',
                                    isHidden: _isPasswordHidden,
                                    controller: _newPasswordController,
                                    onSaved: (input) {
                                      email = input!;
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                    iconWidget: IconButton(
                                      icon: _isPasswordHidden ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                                      color: Colors.blueGrey,
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordHidden = !_isPasswordHidden;
                                        });
                                      },
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                  ),
                                ),
                              ]
                          ) : null
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        margin: const EdgeInsets.only(top: 10.0),
                        child: CustomFormButton(
                          text: 'Update',
                          textColor: Colors.black,
                          fillColor: Colors.orange,
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              updateUserAccount(
                                  context,
                                  _usernameController.text,
                                  _emailController.text,
                                  _profilePicture,
                                  _interests,
                                  () => toggleLoader()
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: CustomFormButton(
                          text: 'Cancel',
                          textColor: Colors.orange,
                          fillColor: const Color(0xFF262626),
                          isLoading: false,
                          onPressed: isLoading ? null : () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        ],
      ),
    );
  }

}