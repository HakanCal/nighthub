
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
                          List<String> testTags = ['shit', 'sexist', 'latin'];
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => EntityPage(
                                entityName: 'PURE x cocolores',
                                address: 'Wagenburgstr. 153',
                                distance: 1.6,
                                tags: testTags,
                                about: 'Keine Genres, keine Grenzen – das COCOLORES verschreibt sich einzig der Liebe zur Musik und der Freude am Tanzen. Als Pop-up-Club auf dem ehemaligen Mainfloor des Pure, mitten im Herzen der Stadt, fügt sich das Coco als willkommener Neuzugang in das Stuttgarter Nachtleben ein. Seit Herbst 2016 verwandelt sich der Club jeden Freitag, Samstag und vor Feiertagen bereits ab 21 Uhr in eine bunte Manege, die mit wundersamer Atmosphäre zum ausgelassenen Feiern einlädt. Im COCOLORES feiert man getreu dem Motto „Kopfüber außer Rand & Band”. Auf der Tanzfläche werden dabei keine Grenzen gesetzt: Zwischen grandiosen Club-Dauerbrennern zu denen alle die Hüften schwingen, Lieblingssongs, bei denen es sich laut mitträllern lässt und Instant Classics ist alles erlaubt – Hauptsache die Stimmung steigt. Die festen Veranstaltungsreihen machen den Besuch im Coco durch besondere Specials noch lohnenswerter. Jeden Freitag wird ab 21 Uhr zum „Coco Friday“ geladen – inklusive freiem Eintritt bis 23 Uhr, einer Flasche Prosecco aufs Haus für alle Mädchen-Trios sowie zahlreichen Getränkespecials an der Bar. Auch Samstags bleibt der Eintritt bei „Cocobella“ bis 23 Uhr frei, während zahlreiche Drinks bis dahin für unter vier Euro über die Theke gehen. Und um dem Begriff „Feiertag“ mal wieder ordentlich Bedeutung zu verleihen, schließt sich Coco an den Abenden vor Feiertagen ihrem Schwesterclub PURE an und feiert die sogenannten „Bottle Nights“, bei denen jede Flaschenbestellung an der Bar direkt verdoppelt wird – zudem spart man sich bis 23 Uhr den Eintrittspreis. Wenn das mal nicht die idealen Voraussetzungen für legendäre Partynächte sind!'
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