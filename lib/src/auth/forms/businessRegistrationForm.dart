import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets.dart';
import '../formFields/index.dart';

class BusinessRegisterForm extends StatefulWidget {
  const BusinessRegisterForm({
    required this.registerBusinessAccount,
    required this.cancel,
    required this.email,
    required this.isLoading,
    required this.toggleLoader
  });

  final String? email;
  final void Function(
    String entityName,
    String email,
    String password,
      String street,
      String postcode,
      String country,
    File? profilePicture,
    List<String> interests,
    void Function() toggleLoader
  ) registerBusinessAccount;
  final void Function() cancel;
  final bool isLoading;
  final void Function() toggleLoader;

  @override
  _BusinessRegisterFormState createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterBusinessFormState');
  final _entityNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _streetController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final imagePicker = ImagePicker();
  final options = ['Club', 'Bar', 'Night Life', 'Live Music', 'Latin'];

  bool _isPasswordHidden = true;
  String entityName = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  final List<String> _interests = [];

  @override
  void initState() {
    _countryController.text = 'DE';
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

  /// Display the country picker (by default is Germany DE)
  void renderCountryPicker(context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      showWorldWide: false,
      onSelect: (Country country) {
        setState(() {
          _countryController.text = country.countryCode;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: 'Entity name',
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
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: 'Email',
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
                    hint: 'Password',
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
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: 'Confirm password',
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
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: 'Street name, Nr.',
                    controller: _streetController,
                    onSaved: (input) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.house_rounded ),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: CustomTextField(
                          hint: 'Postcode',
                          controller: _postCodeController,
                          onSaved: (input) {},
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Empty field';
                            }
                            return null;
                          },
                          iconWidget: null,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                      Flexible(
                        child: Padding (
                          padding: const EdgeInsets.only(left: 40),
                          child: CustomTextField(
                            hint: 'Country',
                            controller: _countryController,
                            onSaved: (input) {},
                            readOnly: true,
                            validator: (value) {
                              if (_postCodeController.text == '') {
                                return '';
                              }
                              return null;
                            },
                            iconWidget: IconButton(
                              icon: const Icon(Icons.arrow_drop_down ),
                              color: Colors.blueGrey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                renderCountryPicker(context);
                              },
                            ),
                            onTap: () {
                              renderCountryPicker(context);
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                    isLoading: widget.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.registerBusinessAccount(
                          _entityNameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _streetController.text,
                          _postCodeController.text,
                          _countryController.text,
                          _profilePicture,
                          _interests,
                          () => widget.toggleLoader()
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
                    onPressed: widget.isLoading ? null : widget.cancel
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