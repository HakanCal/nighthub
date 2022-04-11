import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nighthub/src/auth/formFields/customTextField.dart';
import 'package:nighthub/src/settings/settings.dart';
import 'package:nighthub/src/widgets.dart';
import 'package:provider/provider.dart';

import '../auth/authState.dart';
import '../auth/formFields/customDropdownField.dart';
import '../auth/formFields/customFormButton.dart';
import '../auth/formFields/customImagePicker.dart';


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

  final _formKey = GlobalKey<FormState>(debugLabel: '_EditProfileFormState');

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final imagePicker = ImagePicker();
  final options = ["Club", "Bar", "Night Life", "Live Music", "Latin"];

  bool _isPasswordHidden = true;
  String username = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.userData['username'];
    _emailController.text = widget.userData['email'];
    _interests = getUserInterests(widget.userData['interests']);
    _profilePicture = widget.profilePicture;
  }

  bool isLoading = false;

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

  /// Method for sending a selected or taken photo to the Registration page
  Future selectOrTakePhoto(ImageSource imageSource) async {
    final pickedFile = await imagePicker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path);
      } else {
        _profilePicture = null;
      }
    });
  }

  Future<void> updateUserAccount(BuildContext context, String username, String email, String password, File? profilePicture, List<String> interests, Function() loader) async {

    toggleLoader();

    String? imageName = profilePicture?.path.split('/').last;

    if (imageName != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('/${widget.userData['profile_picture']}');

        await ref.delete()
        .then((value) => Provider.of<AuthState>(context, listen: false).uploadProfilePicture(profilePicture!, imageName));
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref('user_accounts/$userId/');

    realtimeDatabase.update({
      'username': username,
      'profile_picture': imageName,
      'interests': interests
    });

    toggleLoader();

    Navigator.pop(context);
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
      body: SingleChildScrollView(
        child: Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.00),
                      child: CustomTextField(
                        hint: '',
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
                      child: CustomTextField(
                        hint: '',
                        readOnly: true,
                        controller: TextEditingController(
                          text: widget.userData['email']
                        ),
                        onSaved: (input) {
                          email = input!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomTextField(
                        hint: '',
                        controller: TextEditingController(
                          text: widget.userData['password']
                        ),
                        isHidden: _isPasswordHidden,
                        onSaved: (input) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please password cannot be empty';
                          }
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
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      child: CustomImagePicker(
                        profilePicture: _profilePicture,
                        selectOrTakePhoto: selectOrTakePhoto,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      margin: const EdgeInsets.only(top: 10.0),
                      child: CustomFormButton(
                        text: 'Update',
                        textColor: Colors.black,
                        fillColor: Colors.orange,
                        isLoading: false,//widget.isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            updateUserAccount(
                                context,
                                _usernameController.text,
                                _emailController.text,
                                _passwordController.text,
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
                        textColor: Colors.black,
                        fillColor: Colors.orange,
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
      ),
    );
  }

}