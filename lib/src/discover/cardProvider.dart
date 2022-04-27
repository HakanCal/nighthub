import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'entity.dart';

enum CardStatus {
  like,
  dislike
}

class CardProvider extends ChangeNotifier {

  List<Entity> _entities = [];
  List<String> _images = [];

  bool _isDragging = false;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;
  double _angle = 0.00;

  List<Entity> get entities => _entities;
  List<String> get images => _images;
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  CardProvider() {
    resetEntities();
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 35 * x / _screenSize.width;
    notifyListeners();
  }

  void endPosition() {

    _isDragging = false;
    notifyListeners();

    final status = getStatus();

    switch(status) {
      case CardStatus.like:
        like();
        break;
      case CardStatus.dislike:
        dislike();
        break;
      default: resetPosition();
    }

    resetPosition();

  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0.00;
    notifyListeners();
  }

  void resetEntities() {

    _entities = <Entity>[
      Entity(
        name: 'White Noise',
        address: 'Wagenburgstr. 153',
        distance: 1.6,
        tags: ['shit', 'sexist', 'latin'],
        about: 'Keine Genres, keine Grenzen – das COCOLORES verschreibt sich einzig der Liebe zur Musik und der Freude am Tanzen. Als Pop-up-Club auf dem ehemaligen Mainfloor des Pure, mitten im Herzen der Stadt, fügt sich das Coco als willkommener Neuzugang in das Stuttgarter Nachtleben ein. Seit Herbst 2016 verwandelt sich der Club jeden Freitag, Samstag und vor Feiertagen bereits ab 21 Uhr in eine bunte Manege, die mit wundersamer Atmosphäre zum ausgelassenen Feiern einlädt. Im COCOLORES feiert man getreu dem Motto „Kopfüber außer Rand & Band”. Auf der Tanzfläche werden dabei keine Grenzen gesetzt: Zwischen grandiosen Club-Dauerbrennern zu denen alle die Hüften schwingen, Lieblingssongs, bei denen es sich laut mitträllern lässt und Instant Classics ist alles erlaubt – Hauptsache die Stimmung steigt. Die festen Veranstaltungsreihen machen den Besuch im Coco durch besondere Specials noch lohnenswerter. Jeden Freitag wird ab 21 Uhr zum „Coco Friday“ geladen – inklusive freiem Eintritt bis 23 Uhr, einer Flasche Prosecco aufs Haus für alle Mädchen-Trios sowie zahlreichen Getränkespecials an der Bar. Auch Samstags bleibt der Eintritt bei „Cocobella“ bis 23 Uhr frei, während zahlreiche Drinks bis dahin für unter vier Euro über die Theke gehen. Und um dem Begriff „Feiertag“ mal wieder ordentlich Bedeutung zu verleihen, schließt sich Coco an den Abenden vor Feiertagen ihrem Schwesterclub PURE an und feiert die sogenannten „Bottle Nights“, bei denen jede Flaschenbestellung an der Bar direkt verdoppelt wird – zudem spart man sich bis 23 Uhr den Eintrittspreis. Wenn das mal nicht die idealen Voraussetzungen für legendäre Partynächte sind!',
        primaryImage: NetworkImage('https://www.rbb24.de/content/dam/rbb/rbb/rbb24/2022/2022_04/dpa-account/274396294.jpg.jpg/size=708x398.jpg'),
        images: [NetworkImage('https://www.reflect.de/wp-content/uploads/2015/02/news_0115_white-noise1_cmyk_web.jpg'), NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/White_noise.svg/1200px-White_noise.svg.png')],
      ),
      Entity(
        name: 'White Noise',
        address: 'Wagenburgstr. 153',
        distance: 1.6,
        tags: ['shit', 'sexist', 'latin'],
        about: 'Keine Genres, keine Grenzen – das COCOLORES verschreibt sich einzig der Liebe zur Musik und der Freude am Tanzen. Als Pop-up-Club auf dem ehemaligen Mainfloor des Pure, mitten im Herzen der Stadt, fügt sich das Coco als willkommener Neuzugang in das Stuttgarter Nachtleben ein. Seit Herbst 2016 verwandelt sich der Club jeden Freitag, Samstag und vor Feiertagen bereits ab 21 Uhr in eine bunte Manege, die mit wundersamer Atmosphäre zum ausgelassenen Feiern einlädt. Im COCOLORES feiert man getreu dem Motto „Kopfüber außer Rand & Band”. Auf der Tanzfläche werden dabei keine Grenzen gesetzt: Zwischen grandiosen Club-Dauerbrennern zu denen alle die Hüften schwingen, Lieblingssongs, bei denen es sich laut mitträllern lässt und Instant Classics ist alles erlaubt – Hauptsache die Stimmung steigt. Die festen Veranstaltungsreihen machen den Besuch im Coco durch besondere Specials noch lohnenswerter. Jeden Freitag wird ab 21 Uhr zum „Coco Friday“ geladen – inklusive freiem Eintritt bis 23 Uhr, einer Flasche Prosecco aufs Haus für alle Mädchen-Trios sowie zahlreichen Getränkespecials an der Bar. Auch Samstags bleibt der Eintritt bei „Cocobella“ bis 23 Uhr frei, während zahlreiche Drinks bis dahin für unter vier Euro über die Theke gehen. Und um dem Begriff „Feiertag“ mal wieder ordentlich Bedeutung zu verleihen, schließt sich Coco an den Abenden vor Feiertagen ihrem Schwesterclub PURE an und feiert die sogenannten „Bottle Nights“, bei denen jede Flaschenbestellung an der Bar direkt verdoppelt wird – zudem spart man sich bis 23 Uhr den Eintrittspreis. Wenn das mal nicht die idealen Voraussetzungen für legendäre Partynächte sind!',
        primaryImage: NetworkImage('https://c.tenor.com/GgNwQSmjIa0AAAAC/dance-club.gif'),
        images: [NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/White_noise.svg/1200px-White_noise.svg.png'), NetworkImage('https://www.reflect.de/wp-content/uploads/2015/02/news_0115_white-noise1_cmyk_web.jpg')],
      )
    ].reversed.toList();

    notifyListeners();
  }

  CardStatus? getStatus() {
    final x = _position.dx;
    final y = _position.dy;
    const delta = 100;

    if (x >= delta) {
      return CardStatus.like;
    } else if (x <= -delta) {
      return CardStatus.dislike;
    } else if (y <= -delta / 2) {
      return CardStatus.dislike;
    }
    return null;
  }

  Future _nextCard() async {
    if (_images.isEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    images.removeLast();
    resetPosition();
  }

  void dislike() {
    print('dislike');

    _angle = 20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextCard();
    notifyListeners();
  }

  void like() {
    print('like');

    _angle = 20;
    _position += Offset(2 * _screenSize.width, 0);
    _nextCard();
    notifyListeners();
  }

  void initLazyLoader() {
    //TODO: Add 10 Entities to the _entity List<Entity>
  }

  void lazyLoad() {
    //TODO: Add 1 Entity at the End of the List
  }

}