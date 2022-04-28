import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import './swipeCard.dart';

import 'entity.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Discover();
}

class _Discover extends State<Discover> {
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
      initLazyLoader();
    });
  }

  Future<void> initLazyLoader() async {
    final size = MediaQuery.of(context).size;
    setScreenSize(size);

    DatabaseReference realtimeDatabase = FirebaseDatabase.instance.ref();
    realtimeDatabase.child('user_accounts/').orderByKey().limitToFirst(10).get().then((snapshot) {
      Map<dynamic, dynamic> users = snapshot.value as Map;
      users.forEach((key, value) async {
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
              setState(() {
                entities.add(
                    Entity(
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

          /*for (var element in businessPictures.items) {
            print(businessPictures.items.last);
            await element.last.getDownloadURL().then((value) {
              setState(() {
                images?.add(value.toString());
              });
            });
          }*/
          loading = false;
        }
      });
    });
    //TODO: Add 10 Entities to the _entity List<Entity>
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

  /*void resetEntities() {
    setState(() {
      _entities = _entities.reversed.toList();
    });
  }*/

  void dislike() {
    setState(() {
      _angle = 20;
      _position -= Offset(2 * _screenSize.width, 0);
    });
    _nextCard();
  }

  void like() {
    setState(() {
      _angle = 20;
      _position += Offset(2 * _screenSize.width, 0);
    });
    _nextCard();
  }

  Future _nextCard() async {
    print(entities);
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

          return loading == true ? Container(/*TODO: show a spinner when loading*/) : Container(
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
                                // builder: (context) => EntityPage(entity: )) //TODO: with the username or so, get the other images later
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
          );
  }
}