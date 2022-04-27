import 'package:flutter/material.dart';
import 'package:nighthub/src/discover/swipeCard.dart';
import 'package:provider/provider.dart';

import 'cardProvider.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Discover();
}

class _Discover extends State<Discover> {

  final CardProvider cardProv = CardProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      cardProv.setScreenSize(size);
    });
    cardProv.initLazyLoader();
  }

  @override
  Widget build(BuildContext context) {

    const double iconSize = 50.00;

    return Container(
      color: const Color(0xFF262626),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ChangeNotifierProvider(
            create: (context) => CardProvider(),
            child: Flexible(
              flex: 85,
              child: buildCards(cardProv),
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
                        cardProv.dislike();
                        cardProv.lazyLoad();
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_return_rounded),
                      iconSize: 35.00,
                      color: true ? Colors.grey : Colors.yellow[600], //TODO: DO THIS!!!!
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
                          cardProv.like();
                          cardProv.lazyLoad();
                          //Navigator.push(context, MaterialPageRoute(
                          // builder: (context) => EntityPage(entity: ))
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

  Widget buildCards(CardProvider provider) {
    //final images = provider.images;
    final entities = provider.entities;

    return Stack(
      children: entities.map((entity) => SwipeCard(
          entity: entity,
          isFront: entities.last == entity,
      )).toList()
    );
  }

}