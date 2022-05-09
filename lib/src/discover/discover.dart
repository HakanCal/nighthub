import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import './entityPage.dart';
import './swipeCard.dart';
import 'entity.dart';

class Discover extends StatefulWidget {
  const Discover({
    Key? key,
    required this.isBusiness,
  }) : super(key: key);

  final bool isBusiness;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.isBusiness) {
        getBusinessData();
      } else {
        initLazyLoader();
      }
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          loading = false;
        });
      });
    });
  }

  /// Load user-data related to Business-Accounts
  Future<void> getBusinessData() async {
    final size = MediaQuery.of(context).size;
    setScreenSize(size);

    String userId = FirebaseAuth.instance.currentUser!.uid;

    realtimeDatabase.child('user_accounts/$userId/').once().then((event) async {

      final value = event.snapshot.value as dynamic;

      final businessPictures = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('business_pictures/${value['userId']}').listAll();

      if (businessPictures.items.isNotEmpty) {
        await businessPictures.items.last.getDownloadURL().then((value) {
          setState(() {
            primaryImageUrl = value.toString();
          });
        }).catchError((e) {
          debugPrint(e.toString());
        });
      } else {
        setState(() {
          primaryImageUrl = 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.shutterstock.com%2Fimage-vector%2Fuser-account-circle-profile-line-art-272552858&psig=AOvVaw09vPkiqW8eJkZuadboUcDS&ust=1651683080312000&source=images&cd=vfe&ved=0CAwQjRxqFwoTCLi14JHlw_cCFQAAAAAdAAAAABAZ';
        });
      }

      setState(() {
        entities.add(
          Entity(
            userId: value['userId'],
            isBusiness: true,
            username: value['username'],
            address: value['address'],
            distance: 1.6,
            tags: getUserInterests(value['interests']),
            about: value['about'],
            primaryImage: NetworkImage(primaryImageUrl)
          )
        );
      });
    });
  }

  /// Lazy loader fetches the first 30 Business-Accounts (more should be fetched later)
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
                        isBusiness: true,
                        username: value['username'],
                        address: value['address'],
                        distance: 1.6,
                        tags: getUserInterests(value['interests']),
                        about: value['about'],
                        primaryImage: NetworkImage(primaryImageUrl)
                      )
                  );
                });
              }
            });
          }
        }
      });
    });
  }

  /// Sets size of the cards for the swiper
  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  /// Detects the position where the user started to swipe
  void startPosition(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  /// Updates the swipe position while being dragged
  void updatePosition(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _angle = 35 * _position.dx / _screenSize.width;
    });
  }

  /// Detects the final position of the swipe action
  void endPosition() {
    setState(() {
      _isDragging = false;
    });

    final x = _position.dx;
    final y = _position.dy;
    const delta = 100;

    if (x >= delta) {
      final Entity ent = entities.last;
      like();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EntityPage(entity: ent))
      );
    } else if (x <= -delta) {
      dislike();
    } else if (y <= -delta / 2) {
      dislike();
    } else {
      resetPosition();
    }
  }

  /// Resets position od the swiper so cards below are not seen
  void resetPosition() {
    setState(() {
      _isDragging = false;
      _position = Offset.zero;
      _angle = 0;
    });
  }

  /// Attaches the dislike action to the corresponding user in the database
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

  /// Attaches the like action to the corresponding user in the database
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

  /// Next card of the swiper stack will be shown
  Future _nextCard() async {
    if (entities.isEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    removeLastEntity();
    resetPosition();
  }

  /// When swiping to next card the previous one in the array should be removed
  void removeLastEntity() {
    setState(() {
      entities.removeLast();
    });
  }

  /// Converts data related to the user interests into an array
  List<String> getUserInterests(List<dynamic> userData) {
    List<String> list = [];
    for (var elem in userData) {
      list.add(elem);
    }
    return list;
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
      )) : !widget.isBusiness ? Container(
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
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.check_rounded),
                        iconSize: iconSize,
                        color: Colors.green,
                        onPressed: () {
                          final Entity ent = entities.last;
                          like();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EntityPage(entity: ent))
                          );
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