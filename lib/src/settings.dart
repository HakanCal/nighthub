import 'package:flutter/material.dart';

class Settings extends StatefulWidget {

  var marginCards = 5.00;
  var username = 'User 66';
  var email = 'coolguy66@mail.com';
  var interests = ['edm', 'house', 'techno'];

  Widget build(BuildContext context) {
    return Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                Card(
                  color: Colors.grey,
                  margin: EdgeInsets.all(marginCards),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Expanded(
                          flex: 35,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.00),
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage('assets/testProfilePic.png')
                                )
                            ),
                          )
                      ),
                      Expanded(
                          flex: 65,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                                child: Text(
                                  username,
                                  style: TextStyle(fontSize: 25, color: Colors.white),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                                child: Text(
                                  email,
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                                child: Text(
                                  'Interests: \n' + interests.toString().replaceAll("[", "").replaceAll("]", ""),
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.00, vertical: 5.00),
                                child: Text(
                                  'edit profile',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),





                            ],
                          )
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(marginCards),
                    child: Text('What is nightHub?', style: TextStyle(color: Colors.white))
                ),
                Container(
                  margin: EdgeInsets.all(marginCards),
                  child: Text('Impressum', style: TextStyle(color: Colors.white)),
                ),
                Container(
                    margin: EdgeInsets.all(marginCards),
                    child: Text('About', style: TextStyle(color: Colors.white))
                ),
                Container(
                    margin: EdgeInsets.all(marginCards),
                    child: Text('Logout', style: TextStyle(color: Colors.white))
                )
                //NÄCHSTE SPALTE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              ],
            )
    );
  }

}