import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker(
      {this.profilePicture, required this.selectOrTakePhoto});

  final File? profilePicture;
  final Function(ImageSource imageSource) selectOrTakePhoto;

  @override
  _CustomImagePicker createState() => _CustomImagePicker();
}

class _CustomImagePicker extends State<CustomImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _showSelectionDialog();
            },
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 80,
                  backgroundImage: widget.profilePicture == null
                      ? const AssetImage(
                          'assets/user_image.png',
                        )
                      : Image.file(widget.profilePicture!, fit: BoxFit.cover)
                          .image,
                ),
                const SizedBox(height: 10),
                const Text('Please select your profile photo',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.blueGrey))
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Selection dialog that prompts the user to select an existing photo or take a new one
  Future _showSelectionDialog() async {
    await showGeneralDialog(
        context: context,
        transitionBuilder: (context, a1, a2, profilePictureModalWidget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: SimpleDialog(
                  title: const Text('Upload picture'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(children: <Widget>[
                          IconButton(
                            constraints: const BoxConstraints(maxHeight: 36),
                            icon: const Icon(Icons.photo),
                            color: Colors.red,
                            iconSize: 36,
                            onPressed: () {
                              widget.selectOrTakePhoto(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text('Gallery')
                        ]),
                        Column(children: <Widget>[
                          IconButton(
                            constraints: const BoxConstraints(maxHeight: 36),
                            icon: const Icon(Icons.photo_camera),
                            color: Colors.black,
                            iconSize: 36,
                            onPressed: () {
                              widget.selectOrTakePhoto(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text('Camera')
                        ]),
                      ],
                    )
                  ]),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {
          throw Exception;
        });
  }
}
