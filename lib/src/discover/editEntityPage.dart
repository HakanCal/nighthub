import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nighthub/src/discover/discover.dart';
import 'package:nighthub/src/discover/entityPage.dart';
import 'package:provider/provider.dart';

import '../auth/formFields/index.dart';
import '../dialogs/customFadingDialog.dart';

class EditEntityPage extends StatefulWidget {
  const EditEntityPage({
    Key? key,
    required this.userData,
    required this.profilePicture
  }) : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _EditEntityProfile();
}

class _EditEntityProfile extends State<EditEntityPage> {
  late Future<dynamic> _future;
  final _formKey = GlobalKey<FormState>(debugLabel: '_EditEntityPageFormState');

  final _aboutController = TextEditingController();

  final imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];
  File? _profilePicture;

  @override
  void initState() {
    super.initState();

    if (widget.userData['about'] != null) {
      _aboutController.text = widget.userData['about'];
    }

    _future = getImagesArray();
  }

  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> images = [];

  /// Get all the user-related information and load profile picture
  Future<void> getImagesArray() async {
    final businessPictures = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('business_pictures/${widget.userData['userId']}').listAll();

    Future.wait(businessPictures.items.map((e) async {
      await e.getDownloadURL().then((value) {
        setState(() {
          images.add(value.toString());
        });

      });
    })).then((value) {
      if (businessPictures.items.length < 9) {
        int imagesArraySize = businessPictures.items.length;
        for(imagesArraySize; imagesArraySize < 9; imagesArraySize++) {
          setState(() {
            images.add('Add Image');
          });
        }
      }
    });
  }

  /// Show loading spinner when communicating with Firebase
  void toggleLoader() async {
    setState(() {
      isLoading = !isLoading;
    });
  }

  /// Updates the user data if desired
  Future<void> updateBusinessAccount(BuildContext context, String about, Map<String, dynamic> userData, Function() loader) async {

    toggleLoader();

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref('user_accounts/$userId/');

    realtimeDatabase.update({
      'about': about
    });

    toggleLoader();
    showCustomFadingDialog(context, 'Profile updated successfully', Icons.check_circle_outlined, Colors.grey, Colors.green);
  }

  @override
  Widget build(BuildContext context) {

    ScrollController scroller = ScrollController();

    return FutureBuilder<dynamic>(
        future: _future,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFF262626),
            body: ListView(
              shrinkWrap: true,
              controller: scroller,
              addAutomaticKeepAlives: true,
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 48),
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
                              Container(
                                alignment: Alignment.center,
                                child: const Text('Select your pictures',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: buildGridView(scroller)
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 15),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: const Text('Select your text',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: TextFormField(
                                    controller: _aboutController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueGrey),
                                      hintText: 'description',
                                      contentPadding: const EdgeInsets.all(20),
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  )
                              ),
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
                                        _aboutController.text,
                                        () => toggleLoader()
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          )
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
                                    _aboutController.text,
                                    widget.userData,
                                    () => toggleLoader()
                                );
                              }
                            },
                          ),
                        )
                    )
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  Widget buildGridView(ScrollController scroller) => GridView.count(
    shrinkWrap: true,
    controller: scroller,
    crossAxisCount: 3,
    childAspectRatio: 0.65,
    mainAxisSpacing: 3,
    crossAxisSpacing: 3,
    children: List.generate(images.length, (index) {
      if(images[index] != 'Add Image') {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              Image(
                image: images[index] is! File && images[index].contains('https://') ?  NetworkImage(images[index]) : FileImage(images[index]) as ImageProvider,
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
                    if (images[index].contains('https://')) {
                      String imageName = images[index];
                      deleteBusinessPicture(imageName);
                    } else {
                      String imageName = images[index].path.split('/').last;
                      deleteBusinessPicture(imageName);
                    }
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

  /// Selects image from gallery
  Future<void> _onAddImageClick(int index) async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });

      String? imageName = _profilePicture!.path.split('/').last;
      setState(() {
        images.replaceRange(index, index + 1, [_profilePicture]);
      });

      uploadBusinessPicture(_profilePicture!, imageName);
    }
  }

  /// Uploads the selected picture to Firestore Storage
  void uploadBusinessPicture(File profilePicture, String imageName) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('business_pictures/${widget.userData['userId']}')
        .child('/$imageName');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': profilePicture.path});

    firebase_storage.UploadTask uploadTask = ref.putFile(File(profilePicture.path), metadata);
    uploadTask.whenComplete(() {
      debugPrint('Photo was uploaded to storage');
    });
  }

  /// Deletes picture from one of the 9 boxes
  void deleteBusinessPicture(String imageName) async {
    if (imageName.contains('https://')) {
      await firebase_storage.FirebaseStorage.instance.refFromURL(imageName).delete().then((_) {
        debugPrint('Photo was deleted from the database');
      });
    } else {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('business_pictures/${widget.userData['userId']}')
          .child('/$imageName');

      ref.delete().then((_) {
        debugPrint('Photo was deleted from the database');
      });
    }
  }
}
