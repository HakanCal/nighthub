
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth/formFields/customChipList.dart';

class EntityPage extends StatefulWidget {

  const EntityPage({
    Key? key,
    required this.entityName,
    required this.address,
    required this.tags,
    required this.about

  }) : super(key: key);

  final String entityName;
  final String address;
  final List<String> tags;
  final String about;

  @override
  State<StatefulWidget> createState() => _EntityPage();
}

class _EntityPage extends State<EntityPage> {

  final double distance = 1.6;
  final List<String> entityCathegory = ['shit', 'sexist', 'kanacken'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(''),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        controller: ScrollController(),
        addAutomaticKeepAlives: true,

        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Container(
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF262626),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                pictureSwiper(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                entityName(),
                const Padding(padding: EdgeInsets.only(top: 5.00)),
                entityAddress(),
                const Padding(padding: EdgeInsets.only(top: 5.00)),
                entityDistance(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                separationLine(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                Container(
                  child: CustomChipList(
                    values: entityCathegory,
                    chipBuilder: (String value) {
                      return Chip(label: Text(value));
                    },
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                separationLine(),
                const Padding(padding: EdgeInsets.only(top: 15.00)),
                Text(
                  'Keine Genres, keine Grenzen – das COCOLORES verschreibt sich einzig der Liebe zur Musik und der Freude am Tanzen. Als Pop-up-Club auf dem ehemaligen Mainfloor des Pure, mitten im Herzen der Stadt, fügt sich das Coco als willkommener Neuzugang in das Stuttgarter Nachtleben ein. Seit Herbst 2016 verwandelt sich der Club jeden Freitag, Samstag und vor Feiertagen bereits ab 21 Uhr in eine bunte Manege, die mit wundersamer Atmosphäre zum ausgelassenen Feiern einlädt. Im COCOLORES feiert man getreu dem Motto „Kopfüber außer Rand & Band”. Auf der Tanzfläche werden dabei keine Grenzen gesetzt: Zwischen grandiosen Club-Dauerbrennern zu denen alle die Hüften schwingen, Lieblingssongs, bei denen es sich laut mitträllern lässt und Instant Classics ist alles erlaubt – Hauptsache die Stimmung steigt. Die festen Veranstaltungsreihen machen den Besuch im Coco durch besondere Specials noch lohnenswerter. Jeden Freitag wird ab 21 Uhr zum „Coco Friday“ geladen – inklusive freiem Eintritt bis 23 Uhr, einer Flasche Prosecco aufs Haus für alle Mädchen-Trios sowie zahlreichen Getränkespecials an der Bar. Auch Samstags bleibt der Eintritt bei „Cocobella“ bis 23 Uhr frei, während zahlreiche Drinks bis dahin für unter vier Euro über die Theke gehen. Und um dem Begriff „Feiertag“ mal wieder ordentlich Bedeutung zu verleihen, schließt sich Coco an den Abenden vor Feiertagen ihrem Schwesterclub PURE an und feiert die sogenannten „Bottle Nights“, bei denen jede Flaschenbestellung an der Bar direkt verdoppelt wird – zudem spart man sich bis 23 Uhr den Eintrittspreis. Wenn das mal nicht die idealen Voraussetzungen für legendäre Partynächte sind!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.00
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 50.00)),
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }

  Widget separationLine() => Container(
    height: 2,
    width: MediaQuery.of(context).size.width,
    color: const Color(0xFF2F2F2F),
  );

  //TODO: Image swiper
  Widget pictureSwiper() => ClipRRect(
    child: Container(
      width: MediaQuery.of(context).size.height * 0.7,
      height: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
        color: Color(0x8c8c8c8c),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/dance-club.gif'),
        ),
      )
    ),
  );

  Widget entityName() => Container(
    alignment: Alignment.bottomLeft,
    child: Text(
      widget.entityName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 35.00,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget entityAddress() => Row(
    children: [
      const Icon(Icons.location_on_outlined, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10.00)),
      Flexible(
        child: Text(
          widget.address,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.00,
          ),
        ),
      )
    ],
  );

  Widget entityDistance() => Row(
    children: [
      const Icon(Icons.directions_walk, color: Colors.white),
      const Padding(padding: EdgeInsets.only(right: 10.00)),
      Flexible(
        child: Text(
          '$distance km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.00,
          ),
        ),
      )
    ],
  );

}