import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nighthub/src/discover/discover.dart';
import 'package:provider/provider.dart';

import '../auth/authState.dart';
import '../auth/formFields/index.dart';
import '../dialogs/customFadingDialog.dart';
import '../settings/settings.dart';


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

  final _formKey = GlobalKey<FormState>(debugLabel: '_EditEntityPageFormState');

  final _aboutController = TextEditingController();

  final imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  @override
  void initState() {
    super.initState();

    if (widget.userData['about'] != null) {
      _aboutController.text = widget.userData['about'];
    }


    for (int i = 0; i < 9; i++) {
      images.add("Add Image");
    }

  }

  bool isLoading = false;
  String errorMessage = '';

  /// Show loading spinner when communicating with Firebase
  void toggleLoader() async {
    setState(() {
      isLoading = !isLoading;
    });
  }

  /// Updates the user data if desired
  Future<void> updateBusinessAccount(BuildContext context, String about, Function() loader) async {

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

    return Scaffold(
      backgroundColor: const Color(0xFF262626),
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
                        Container(
                          alignment: Alignment.center,
                          child: const Text('Select your pictures', style: TextStyle(color: Colors.white, fontSize: 20.00)),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            margin: const EdgeInsets.only(top: 10.0),
                            child: buildGridView(scroller)
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: const Text('Select your text', style: TextStyle(color: Colors.white, fontSize: 20.00)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          margin: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: _aboutController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
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
                                    () => toggleLoader()
                                );
                              }
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
