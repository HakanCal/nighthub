import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/authState.dart';
import '../auth/formFields/index.dart';
import 'package:nighthub/src/settings/settings.dart';

import '../dialogs/customFadingDialog.dart';


class EditBusinessProfile extends StatefulWidget {
  const EditBusinessProfile({
    Key? key,
    required this.userData,
    required this.profilePicture
  }) : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _EditBusinessProfile();
}

class _EditBusinessProfile extends State<EditBusinessProfile> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EditProfileFormState');

  final _entityNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '<your password>');
  final _streetController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _aboutController = TextEditingController();

  final imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];
  final options = ['Nightclub','Dance','Club','Bar','Night Life','Live Music','Latin','Festival','Event','Drinks','Cafe','Rock','Jazz','Metal','EDM','Pop','Techno','Electro','Hip Hop','Rap','Punk'];

  String username = '';
  String email = '';
  String password = '';
  File? _profilePicture;
  List<String> _interests = [];


  @override
  void initState() {
    super.initState();
    _entityNameController.text = widget.userData['username'];
    _emailController.text = widget.userData['email'];
    _interests = getUserInterests(widget.userData['interests']);
    _profilePicture = widget.profilePicture;
    _streetController.text = widget.userData['address'].toString().split(",")[0];
    _postCodeController.text = widget.userData['address'].toString().split(",")[1];
    _countryController.text = widget.userData['address'].toString().split(",")[2];


    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
    images.add("Add Image");
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

  /// Updates the user data if desired
  Future<void> updateBusinessAccount(
      BuildContext context,
      String entityName,
      String email,
      String password,
      String street,
      String postcode,
      String country,
      File? profilePicture,
      List<String> interests,
      Function() loader
      ) async
  {
    toggleLoader();

    String? imageName = profilePicture?.path.split('/').last;

    if (imageName != widget.userData['profile_picture']) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('/${widget.userData['profile_picture']}');

      await ref.delete()
          .then((value) => Provider.of<AuthState>(context, listen: false).uploadProfilePicture(profilePicture!, imageName!));
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref('user_accounts/$userId/');

    realtimeDatabase.update({
      'username': entityName,
      'address': '$street, $postcode, $country',
      'profile_picture': imageName,
      'interests': interests
    });

    toggleLoader();
    Navigator.pop(context);

    showCustomFadingDialog(context, 'Profile changed successfully', Icons.check_circle_outlined, Colors.grey, Colors.green);

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
                                hint: '',
                                controller: _entityNameController,
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            child: CustomFormButton(
                              text: 'Change Password via Email',
                              textColor: Colors.black,
                              fillColor: Colors.orange,
                              isLoading: false,
                              onPressed: () async {

                                String msg = 'You have been sent an email';
                                showCustomFadingDialog(context, msg, Icons.mail_outline, Colors.grey, Colors.blue);

                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: widget.userData['email']);

                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20.00),
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
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10.00),
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
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10.00),
                          ),


                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            margin: const EdgeInsets.only(top: 10.0),
                            child: buildGridView(scroller)
                          ),


                          const Padding(
                            padding: EdgeInsets.only(bottom: 10.00),
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
                                  updateBusinessAccount(
                                    context,
                                    _entityNameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                    _streetController.text,
                                    _postCodeController.text,
                                    _countryController.text,
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
          ],
        ),
      );
  }


  final multiPicker = ImagePicker();
  List images = [];
  late Future _imageFile;


  Widget buildGridView(ScrollController scroller) => GridView.count(
    shrinkWrap: true,
    controller: scroller,
    crossAxisCount: 3,
    childAspectRatio: 0.65,
    mainAxisSpacing: 3,
    crossAxisSpacing: 3,
    children: List.generate(images.length, (index) {
      if(images[index] is ImageUploadModel) {
        ImageUploadModel uploadModel = images[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              Image.file(
                uploadModel.imageFile,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: InkWell(
                  child: const Icon(
                    Icons.remove_circle,
                    size: 20,
                    color: Colors.red,
                  ),
                  onTap: () {
                    setState(() {
                      images.replaceRange(index, index + 1, ['Add Image']);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return Card(
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _onAddImageClick(index);
            },
          ),
        );
      }
    }),

  );


  /*
  Widget buildGridView() => InkWell(
    onTap: () {
      //getMultiImages();
    },
    child: GridView.builder(
      itemCount: 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3
      ),
      itemBuilder: (context, index) => Container(/*
        color: Colors.grey,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5))
        ),
        child: /*images!.isEmpty ?*/
         Icon(
          CupertinoIcons.camera,
          color: Colors.grey.withOpacity(0.5),
        ) /*: Image.file(File(images![index].path),
        fit: BoxFit.cover)*/,
      */),
    ),
  );*/

  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker().pickImage(source: ImageSource.gallery);
      getFileImage(index);
    });
  }

  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();

    _imageFile.then((file) async {
      setState(() {
        ImageUploadModel imageUpload = ImageUploadModel(isUploaded: false, uploading: false, imageFile: File(file.path), imageUrl: '');
        images.replaceRange(index, index + 1, [imageUpload]);
      });
    });
  }
}

/*
  Future getMultiImages() async {
    final List<XFile>? selectedImages = await multiPicker.pickMultiImage();
    setState(() {
      if(selectedImages!.isNotEmpty) {
        images!.addAll(selectedImages);
      } else {
        print('No images selected');
      }
    });
  }*/


  class ImageUploadModel {
    bool isUploaded;
    bool uploading;
    File imageFile;
    String imageUrl;

    ImageUploadModel({
    required this.isUploaded,
    required this.uploading,
    required this.imageFile,
    required this.imageUrl,
    });
  }
