import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'auth/authState.dart';
import 'auth/formFields/customChipList.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({required this.userData, required this.profilePicture, Key? key}) : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _AppSettings();

}

class _AppSettings extends State<AppSettings> {

  double marginCards = 5;
  String username = "";
  String email = "";
  List<dynamic> interests = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

        return Container(
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF262626),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 15, bottom: marginCards+5),
                  padding: EdgeInsets.symmetric(vertical: marginCards + 5),
                  decoration: const BoxDecoration(
                    color: Color(0x8c8c8c8c),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 60,
                        backgroundImage: widget.profilePicture == null
                            ? const AssetImage('assets/user_image.png',)
                            : Image.file(widget.profilePicture!, fit: BoxFit.cover).image,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(widget.userData['username'], style: const TextStyle(fontSize: 30, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(widget.userData['email'], style: const TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CustomChipList(
                          values: getUserInterests(widget.userData['interests']),
                          chipBuilder: (String value) {
                            return Chip(label: Text(value));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              AddItem(iconData: Icons.question_mark, text: 'What is nightHub', onPress: () => {}),
              AddItem(iconData: Icons.wrap_text, text: 'Impressum', onPress: () => {}),
              AddItem(iconData: Icons.abc_rounded, text: 'About', onPress: () => {}),
              AddItem(iconData: Icons.logout, text: 'Log out', onPress: () {
                Provider.of<AuthState>(context, listen: false).logOut();
                Navigator.pushNamed(context, '/');
              }),
            ],
          )
      )
        );
  }
}

//Settings Item Logo + Text
class AddItem extends StatefulWidget {
  //Widget parameters
  const AddItem({
    required this.iconData,
    required this.text,
    required this.onPress
  });
  
  //Hard coded values
  final Color iconColor = Colors.white;
  final Color itemColor = const Color(0x8c8c8c8c);
  final double iconSize = 30;
  final double fontSize = 20;
  final double itemPadding = 5;
  final double borderRadius = 15;

  //Variable values
  final IconData iconData;
  final String text;
  final Function() onPress;

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: widget.itemPadding),
      decoration: BoxDecoration(
        color: widget.itemColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      child: TextButton(
        onPressed: widget.onPress,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                widget.iconData,
                color: widget.iconColor,
                size: widget.iconSize,
              )
            ),
            Text(widget.text, style: TextStyle(color: Colors.white, fontSize: widget.fontSize))
          ],
        ),
      ),
    );
  }
}

List<String> getUserInterests(List<dynamic> userData) {
  List<String> list = [];
  for (var elem in userData) {
    list.add(elem);
  }
  return list;
}
