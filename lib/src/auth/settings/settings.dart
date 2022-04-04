import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nighthub/src/auth/settings/editProfile.dart';

import '../formFields/customChipList.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({required this.userData, Key? key}) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  State<StatefulWidget> createState() => _AppSettings();

}

class _AppSettings extends State<AppSettings> {

  double marginCards = 5.00;
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
        color: const Color(0xFF262626),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Oben anfangen lassen
            children: <Widget>[
              //Profile bubble
              Flexible(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0x8c8c8c8c),
                    borderRadius: BorderRadius.all(Radius.circular(15.00)),
                  ),
                  margin: EdgeInsets.fromLTRB(marginCards, marginCards+5.00, marginCards, marginCards+5.00),
                  padding: const EdgeInsets.symmetric(vertical: 25.00),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15.00)),
                        ),
                        child: Column(
                          children: [
                            const ProfilePic(width: 150.00, height: 150.00, imgPath: 'assets/dummy-profile-pic.png'),
                            Text(widget.userData['username'], style: const TextStyle(fontSize: 30, color: Colors.white)),
                            Text(widget.userData['email'], style: const TextStyle(fontSize: 20, color: Colors.white)),
                            CustomChipList(
                              values: getUserInterests(widget.userData['interests']),
                              chipBuilder: (String value) {
                                return Chip(label: Text(value));
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AddItem(margin: marginCards, iconData: Icons.question_mark, text: 'What is nightHub'),
                    AddItem(margin: marginCards, iconData: Icons.wrap_text, text: 'Impressum'),
                    AddItem(margin: marginCards, iconData: Icons.abc_rounded, text: 'About'),
                    AddItem(margin: marginCards, iconData: Icons.logout, text: 'Logout')
                  ],
                ),
              )
            ]
          )
      );
  }
}

  //Settings Item Logo + Text
  class AddItem extends StatefulWidget {

    //Hard coded values
    final Color iconColor = Colors.white;
    final Color itemColor = const Color(0x8c8c8c8c);
    final double iconSize = 30.00;
    final double fontSize = 20.00;
    final double itemPadding = 12.00;
    final double borderRadius = 15.00;

    //Variable values
    final double margin;
    final IconData iconData;
    final String text;

    //Widget parameters
    const AddItem({Key? key,required this.margin, required this.iconData, required this.text}) : super(key: key);

    @override
    _AddItemState createState() => _AddItemState();
  }

  class _AddItemState extends State<AddItem> {

    @override
    Widget build(BuildContext context) {

      return Container(
        margin: EdgeInsets.all(widget.margin),
        padding: EdgeInsets.symmetric(vertical: widget.itemPadding),
        decoration: BoxDecoration(
          color: widget.itemColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        ),
        child: Row(
            children: <Widget>[
              Expanded(
                flex: 12,
                child: Icon(
                  widget.iconData,
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
              Expanded(
                flex: 88,
                  child: Text(widget.text, style: TextStyle(color: Colors.white, fontSize: widget.fontSize))
              )
            ],
          ),
      );
    }
  }

  class ProfilePic extends StatefulWidget {

    final double width;
    final double height;
    final String imgPath;

    const ProfilePic({Key? key, required this.width, required this.height, required this.imgPath}) : super(key: key);
    @override
    _ProfilePic createState() => _ProfilePic();
  }

  class _ProfilePic extends State<ProfilePic> {
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0.00, 0.00, 0.00, 10.00),
        width: widget.width,
        height: widget.height,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/dummy-profile-pic.png')
          )
        )
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
