import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/authState.dart';
import '../auth/formFields/index.dart';
import './settings.dart';
import '../dialogs/customFadingPopup.dart';

class EditBusinessProfile extends StatefulWidget {
  const EditBusinessProfile(
      {Key? key, required this.userData, required this.profilePicture})
      : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _EditBusinessProfile();
}

class _EditBusinessProfile extends State<EditBusinessProfile> {
  final userCredentials = FirebaseAuth.instance.currentUser;

  final _formKey =
      GlobalKey<FormState>(debugLabel: '_EditBusinessProfileFormState');
  final _entityNameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _streetController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _countryController = TextEditingController();

  final imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];
  final options = [
    'Nightclub',
    'Dance',
    'Club',
    'Bar',
    'Night Life',
    'Live Music',
    'Latin',
    'Festival',
    'Event',
    'Drinks',
    'Cafe',
    'Rock',
    'Jazz',
    'Metal',
    'EDM',
    'Pop',
    'Techno',
    'Electro',
    'Hip Hop',
    'Rap',
    'Punk'
  ];

  String username = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _entityNameController.text = widget.userData['username'];
    _emailController = TextEditingController(text: widget.userData['email']);
    _interests = getUserInterests(widget.userData['interests']);
    _profilePicture = widget.profilePicture;
    _streetController.text =
        widget.userData['address'].toString().split(',')[0];
    _postCodeController.text =
        widget.userData['address'].toString().split(',')[1].replaceAll(' ', '');
    _countryController.text =
        widget.userData['address'].toString().split(',')[2].replaceAll(' ', '');
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

  /// Method for selecting a new profile picture
  Future selectOrTakePhoto(ImageSource imageSource) async {
    final pickedFile = await imagePicker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path);
      }
    });
  }

  /// Creates geohash, longitude and latitude from address
  Future<Object> createGeoPoint(String address) async {
    var point = {};
    List<Location> locations = await locationFromAddress(address);

    try {
      GeoHash geoHash = GeoHash.fromDecimalDegrees(
          locations[0].longitude, locations[0].latitude);
      point = {
        'geohash': geoHash.geohash,
        'geopoint': {
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude
        }
      };
    } catch (e) {
      debugPrint(e.toString());
    }
    return point;
  }

  /// Updates the user data if desired
  Future<void> updateBusinessAccount(
      BuildContext context,
      String entityName,
      String email,
      String street,
      String postcode,
      String country,
      File? profilePicture,
      List<String> interests,
      Function() loader) async {
    toggleLoader();

    if (email.isNotEmpty && email != widget.userData['email']) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: widget.userData['email'],
        password: _currentPasswordController.text,
      )
          .then((value) {
        userCredentials?.updateEmail(email).then((value) {
          debugPrint('Email was updated');
        }).catchError((onError) {
          setState(() {
            errorMessage = 'Email empty or wrong format';
          });
        });
      });
    }

    if (_newPasswordController.text.isNotEmpty) {
      await userCredentials
          ?.updatePassword(_newPasswordController.text)
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
      setState(() {
        errorMessage = '';
      });
    } else {
      String? imageName = profilePicture?.path.split('/').last;

      if (imageName != widget.userData['profile_picture'] && widget.userData['profile_picture'] != 'null') {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('/${widget.userData['profile_picture']}');

        await ref.delete().then((value) =>
            Provider.of<AuthState>(context, listen: false)
                .uploadProfilePicture(profilePicture!, imageName!));
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference realtimeDatabase =
          FirebaseDatabase.instance.ref('user_accounts/$userId/');

      String address = '$street , $postcode, $country';
      var point = await createGeoPoint(address);

      realtimeDatabase.update({
        'username': entityName,
        'email': email,
        'address': address,
        'point': point,
        'profile_picture': imageName ?? 'null',
        'interests': interests
      });

      toggleLoader();
      Navigator.pop(context);
      showCustomFadingDialog(context, 'Profile updated successfully',
          Icons.check_circle_outlined, Colors.grey, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scroller = ScrollController();

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
        shrinkWrap: true,
        controller: scroller,
        addAutomaticKeepAlives: true,
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 15),
                          child: CustomImagePicker(
                            profilePicture: _profilePicture,
                            selectOrTakePhoto: selectOrTakePhoto,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: CustomTextField(
                              hint: 'Name Business',
                              controller: _entityNameController,
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
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus()),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
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
                              icon: const Icon(Icons.house_rounded),
                              color: Colors.blueGrey,
                              onPressed: () {},
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
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
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
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
                                        icon: const Icon(Icons.arrow_drop_down),
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
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context).unfocus(),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
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
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(_isUpdateEmail
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                  color: Colors.orange,
                                  onPressed: () {
                                    setState(() {
                                      _isUpdateEmail = !_isUpdateEmail;
                                    });
                                  },
                                )
                              ],
                            )),
                        Container(
                            child: _isUpdateEmail
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: CustomTextField(
                                            hint: 'New Email',
                                            controller: _emailController,
                                            onSaved: (input) {
                                              email = input!;
                                            },
                                            validator: (value) {
                                              if (_isUpdateEmail &&
                                                  value!.isEmpty) {
                                                return 'Please email cannot be empty';
                                              }
                                              return null;
                                            },
                                            iconWidget: IconButton(
                                              icon: const Icon(Icons.email),
                                              color: Colors.blueGrey,
                                              onPressed: () {},
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .nextFocus(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 10),
                                          child: CustomTextField(
                                            hint: 'Current password',
                                            isHidden: true,
                                            controller:
                                                _currentPasswordController,
                                            onSaved: (input) {
                                              email = input!;
                                            },
                                            validator: (value) {
                                              if (_isUpdateEmail &&
                                                  value!.isEmpty) {
                                                return 'Please password cannot be empty';
                                              }
                                              return null;
                                            },
                                            iconWidget: IconButton(
                                              icon: const Icon(
                                                  Icons.password_outlined),
                                              color: Colors.blueGrey,
                                              onPressed: () {},
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                          ),
                                        ),
                                      ])
                                : null),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Row(
                              children: [
                                const Text(
                                  'Update Password',
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(_isUpdatePassword
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                  color: Colors.orange,
                                  onPressed: () {
                                    setState(() {
                                      _isUpdatePassword = !_isUpdatePassword;
                                    });
                                  },
                                )
                              ],
                            )),
                        Container(
                            child: _isUpdatePassword
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
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
                                              icon: _isPasswordHidden
                                                  ? const Icon(
                                                      Icons.visibility_off)
                                                  : const Icon(
                                                      Icons.visibility),
                                              color: Colors.blueGrey,
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordHidden =
                                                      !_isPasswordHidden;
                                                });
                                              },
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                          ),
                                        ),
                                      ])
                                : null),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          margin: const EdgeInsets.only(top: 10),
                          child: CustomFormButton(
                            text: 'Update',
                            textColor: Colors.black,
                            fillColor: Colors.orange,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                updateBusinessAccount(
                                    context,
                                    _entityNameController.text,
                                    _emailController.text,
                                    _streetController.text,
                                    _postCodeController.text,
                                    _countryController.text,
                                    _profilePicture,
                                    _interests,
                                    () => toggleLoader());
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: CustomFormButton(
                            text: 'Cancel',
                            textColor: Colors.orange,
                            fillColor: const Color(0xFF262626),
                            isLoading: false,
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
