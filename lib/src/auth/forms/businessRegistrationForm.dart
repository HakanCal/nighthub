import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets.dart';
import '../formFields/index.dart';

class BusinessRegisterForm extends StatefulWidget {
  const BusinessRegisterForm({
    required this.registerBusinessAccount,
    required this.cancel,
    required this.email,
  });

  final String? email;
  final void Function(
    String entityName,
    String email,
    String password,
    File? profilePicture,
    List<String> interests,
  ) registerBusinessAccount;
  final void Function() cancel;

  @override
  _BusinessRegisterFormState createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterBusinessFormState');
  final _entityNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final imagePicker = ImagePicker();
  final options = ["Club", "Bar", "Night Life", "Live Music", "Latin"];

  bool _isPasswordHidden = true;
  String entityName = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  final List<String> _interests = [];

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

  /// Method for sending a selected or taken photo to the EditPage
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
    return Column(
      children: [
        const Header('Create account'),
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
                    hint: "Entity name",
                    controller: _entityNameController,
                    onSaved: (input) {
                      entityName = input!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please entity name cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.account_circle_rounded),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: "Email",
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: "Password",
                    controller: _passwordController,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: "Confirm password",
                    controller: _confirmPasswordController,
                    isHidden: true,
                    onSaved: (input) {
                      password = input!;
                    },
                    validator: (value) {
                      if (value!.isEmpty || value != _passwordController.text) {
                        return 'Passwords should match';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.password_rounded ),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
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
                    selectOrTakePhoto: selectOrTakePhoto,),
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
                        widget.registerBusinessAccount(
                          _entityNameController.text,
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