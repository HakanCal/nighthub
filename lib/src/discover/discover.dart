
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:nighthub/src/discover/entityPage.dart';
import 'package:nighthub/src/discover/swipeCard.dart';
import 'package:provider/provider.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Discover();
}

class _Discover extends State<Discover> {

  Stack<Object> history = Stack<Object>();
  Queue<Object> loadedEntities = Queue<Object>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    const double iconSize = 50.00;
    
    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF262626),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ChangeNotifierProvider(
            create: (context) => CardProvider(),
            child: const Flexible(
              flex: 85,
              child: SwipeCard(imageUrl: 'assets/dummy-club.png')
            ),
          ),
          Flexible(
            flex: 13,
            child: Container(
              decoration: const BoxDecoration(
                //color: Color(0x8c8c8c8c),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              alignment: Alignment.center, //TODO: Check if thats right?
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      iconSize: iconSize,
                      color: Colors.red,
                      onPressed: () {
                        //TODO: onPressed Action -> Say no to club
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_return_rounded),
                      iconSize: 35.00,
                      color: history.isEmpty ? Colors.grey : Colors.yellow[600],
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
                          List<String> testTags = ['Test', 'yay', 'ilike'];
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => EntityPage(
                                entityName: "PURE x cocolores",
                                address: "Wagenburgstr. 153",
                                tags: testTags,
                                about: "Lorem ipsum dolore est"
                            ))
                          );
                          //TODO: onPressed Action -> Say yes to a club
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

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}