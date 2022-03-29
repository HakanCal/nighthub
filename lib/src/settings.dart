import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {

  const Settings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Settings();



}

class _Settings extends State<Settings> {

  var marginCards = 0.00;
  String username = "";
  String email = "";
  List<dynamic> interests = [];


  Future<void> loadUserData() async {

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    FirebaseFirestore.instance
        .collection('user_accounts')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.size > 0) {
            for (final document in querySnapshot.docs) {

              Map<String, dynamic>? fetchDoc = document.data() as Map<String, dynamic>?;

              setState(() {

                username = fetchDoc?['username'];
                email = fetchDoc?['email'];
                interests = fetchDoc?['interests'];

              });
            }
          } else {
            print("Fucks not working");
          }
        }
      );
  }

  late Future<void> _future;

  @override
  void initState() {
    _future = loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _future,
      builder: (context, AsyncSnapshot<dynamic> snapshot){
        return Container(
          color: const Color(0xFF262626),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Oben anfangen lassen
            children: <Widget>[

              //Profile bubble

              Container(
                decoration: const BoxDecoration(
                  color: Color(0x8c8c8c8c),
                  borderRadius: BorderRadius.all(Radius.circular(15.00)),
                ),
                margin: EdgeInsets.fromLTRB(marginCards, marginCards, marginCards, marginCards+15.00),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 40,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(15.00, 0.00, 10.00, 0.00),
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('assets/dummy-profile-pic.png')
                              )
                          ),
                        )
                    ),
                    Expanded(
                        flex: 65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(margin: const EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                              child: Text(username, style: const TextStyle(fontSize: 25, color: Colors.white),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                              child: Text(email, style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomChipList(
                                    values: interests,
                                    chipBuilder: (String value) {
                                      return Chip(label: Text(value));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),
              AddItem(margin: marginCards, iconData: Icons.question_mark, text: 'What is nightHub'),
              AddItem(margin: marginCards, iconData: Icons.wrap_text, text: 'Impressum'),
              AddItem(margin: marginCards, iconData: Icons.abc_rounded, text: 'About'),
              AddItem(margin: marginCards, iconData: Icons.logout, text: 'Logout')
            ],
          )
      );
      },
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

