import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets.dart';
import '../formFields/customDropdownField.dart';
import '../formFields/customFormButton.dart';
import '../formFields/customImagePicker.dart';
import '../formFields/customTextField.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({required this.userData, required this.registerUserAccount, required this.cancel, required this.email, Key? key}) : super(key: key);

  final String? email;
  final void Function(
      String username,
      String email,
      String password,
      File? profilePicture,
      List<String> interests,
      ) registerUserAccount;
  final void Function() cancel;

  final Map<String, dynamic> userData;

  @override
  State<StatefulWidget> createState() => _EditProfile();

}

class _EditProfile extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterUserFormState');
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final imagePicker = ImagePicker();
  final options = ["Club", "Bar", "Night Life", "Live Music", "Latin"];

  String username = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  late final List<String> _interests;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {

    username = widget.userData['username'];
    email = widget.userData['email'];
    //_profilePicture = widget.userData['profilepicture'];
    _interests = widget.userData['interests'];

    return Column(
      children: [
        const Header('Configure account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: widget.userData['username'],
                    controller: _usernameController,
                    onSaved: (input) {
                      username = input!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
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
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: widget.userData['email'],
                    controller: _emailController,
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
                    hint: "Password",
                    controller: _passwordController,
                    isHidden: true,
                    onSaved: (input) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please password cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.visibility_off),
                      color: Colors.blueGrey, onPressed: () {  },
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomDropdownField(
                    values: _interests,
                    hintText: 'Select interests',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomImagePicker(
                    profilePicture: _profilePicture,
                    selectOrTakePhoto: selectOrTakePhoto,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: CustomFormButton(
                    text: 'Create',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.registerUserAccount(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _profilePicture,
                          _interests,
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
                    onPressed: widget.cancel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}