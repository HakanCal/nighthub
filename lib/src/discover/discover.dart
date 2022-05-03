import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nighthub/src/discover/entityPage.dart';
import './swipeCard.dart';

import 'entity.dart';

class Discover extends StatefulWidget {

  const Discover({
    Key? key,
    required this.userData
  }) : super(key: key);

  final Map<String, dynamic> userData;


  @override
  State<StatefulWidget> createState() => _Discover();
}

class _Discover extends State<Discover> {
  DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref();
  bool loading = true;

  List<Entity> entities = [];
  String primaryImageUrl = '';
  bool _isDragging = false;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;
  double _angle = 0;

  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  bool get isBusiness => widget.userData['business'];

  @override
  void initState() {
    super.initState();
    print('Initializing Discover...');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!isBusiness) {
        initLazyLoader();
      } else {
        getBusinessData();
      }
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          loading = false;
        });
      });
    });
  }

  //Load user Data
  Future<void> getBusinessData() async {
    final size = MediaQuery.of(context).size;
    setScreenSize(size);

    String userId = FirebaseAuth.instance.currentUser!.uid;

    realtimeDatabase.child('user_accounts/$userId/').onValue.listen((event) async {

      final value = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      final businessPictures = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('business_pictures/${value['userId']}').listAll();

      if (businessPictures.items.isNotEmpty) {
        await businessPictures.items.last.getDownloadURL().then((value) {
          setState(() {
            primaryImageUrl = value.toString();
          });
        });
      }
      setState(() {
        entities.add(
          Entity(
            userId: value['userId'],
            isBusiness: value['business'],
            username: value['username'],
            address: value['address'],
            distance: 1.6,
            tags: getUserInterests(value['interests']),
            about: value['about'],
            primaryImage: NetworkImage(primaryImageUrl),
            /*images: [
                NetworkImage(images![images!.length - 2]),
              ],*/
          )
        );
      });
    });
  }

  //Lazy loader
  Future<void> initLazyLoader() async {
    final size = MediaQuery.of(context).size;
    setScreenSize(size);

    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    realtimeDatabase.child('user_accounts/').orderByKey().limitToFirst(30).get().then((snapshot) {
      Map<dynamic, dynamic> users = snapshot.value as Map;
      users.forEach((key, value) async {
        bool dislike = false;

        if(value['business'] == true) {
          final businessPictures = await firebase_storage.FirebaseStorage.instance
              .ref()
              .child('business_pictures/${value['userId']}').listAll();

          if (businessPictures.items.isNotEmpty) {
            await businessPictures.items.last.getDownloadURL().then((value) {
              setState(() {
                primaryImageUrl = value.toString();
              });
            }).then((_) {
              if (value['dislikes'] != null) {
                Map<dynamic, dynamic> dislikes = value['dislikes'] as Map;
                dislikes.forEach((key, userDislike) {
                  if (userDislike == currentUserID) {
                    dislike = true;
                  }
                });
              }
              if (dislike == false) {
                setState(() {
                  entities.add(
                      Entity(
                        userId: value['userId'],
                        isBusiness: value['business'],
                        username: value['username'],
                        address: value['address'],
                        distance: 1.6,
                        tags: getUserInterests(value['interests']),
                        about: value['about'],
                        primaryImage: NetworkImage(primaryImageUrl),
                        /*images: [
                            NetworkImage(images![images!.length - 2]),
                          ],*/
                      )
                  );
                });
              }
            });
          }

          /*for (var element in businessPictures.items) {
            print(businessPictures.items.last);
            await element.last.getDownloadURL().then((value) {
              setState(() {
                images?.add(value.toString());
              });
            });
          }*/
        }
      });
    });
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void updatePosition(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _angle = 35 * _position.dx / _screenSize.width;
    });
  }

  void endPosition() {
    setState(() {
      _isDragging = false;
    });

    final x = _position.dx;
    final y = _position.dy;
    const delta = 100;

    if (x >= delta) {
      like();
    } else if (x <= -delta) {
      dislike();
    } else if (y <= -delta / 2) {
      dislike();
    } else {
      resetPosition();
    }
  }

  void resetPosition() {
    setState(() {
      _isDragging = false;
      _position = Offset.zero;
      _angle = 0;
    });
  }

  void dislike() {
    String businessUserID = entities.last.userId;
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref('user_accounts/$businessUserID/dislikes');

    realtimeDatabase.push().set(currentUserID);
    setState(() {
      _angle = 20;
      _position -= Offset(2 * _screenSize.width, 0);
    });
    _nextCard();
  }

  void like() {
    String businessUserID = entities.last.userId;
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref('user_accounts/$businessUserID/likes');

    realtimeDatabase.push().set(currentUserID);
    setState(() {
      _angle = 20;
      _position += Offset(2 * _screenSize.width, 0);
    });
    _nextCard();
  }

  Future _nextCard() async {
    if (entities.isEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    removeLastEntity();
    resetPosition();
  }

  void removeLastEntity() {
    setState(() {
      entities.removeLast();
    });
  }

  List<String> getUserInterests(List<dynamic> userData) {
    List<String> list = [];
    for (var elem in userData) {
      list.add(elem);
    }
    return list;
  }

  void lazyLoad() {
    //TODO: Add 1 Entity at the End of the List
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 50;

    return loading == true ? Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/nighthub.png', width: 200, height: 200, fit: BoxFit.contain),
          const SpinKitFadingCircle(
            color: Colors.orange,
            size: 60,
          ) ,
        ],
      )) : !isBusiness ? Container(
      color: const Color(0xFF262626),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Flexible(
            flex: 85,
            child: Stack(
              clipBehavior: Clip.none,
              children: entities.map((entity) =>
                SwipeCard(
                  entity: entity,
                  isFront: entities.last == entity,
                  setScreenSize: setScreenSize,
                  position: position,
                  isDragging: isDragging,
                  angle: angle,
                  startPosition: startPosition,
                  updatePosition: updatePosition,
                  endPosition: endPosition,
                )).toList(),
            ),
          ),
          Flexible(
              flex: 13,
              child: Container(
                decoration: const BoxDecoration(
                  //color: Color(0x8c8c8c8c),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        iconSize: iconSize,
                        color: Colors.red,
                        onPressed: () {
                          dislike();
                          lazyLoad();
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_return_rounded),
                        iconSize: 35,
                        color: true ? Colors.grey : Colors.yellow[600],
                        //TODO: DO THIS!!!!
                        onPressed: () {
                          //TODO: return to last Club
                          //TODO: start grey, get yellow when rollback is avaliable
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.check_rounded),
                        iconSize: iconSize,
                        color: Colors.green,
                        onPressed: () {
                          like();
                          lazyLoad();
                          //Navigator.push(context, MaterialPageRoute(
                          // builder: (context) => EntityPage(entity: )) //TODO: with the userId or so, get the other images later
                          //);
                        },
                      ),
                    )
                  ],
                ),
              )
          )
        ],
      ),
    ) : EntityPage(
        entity: entities[0]
    );
  }
}