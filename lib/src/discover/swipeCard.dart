
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nighthub/src/auth/formFields/customChipList.dart';
import 'package:provider/provider.dart';

class SwipeCard extends StatefulWidget {

  final String imageUrl;
  final bool isFront;

  const SwipeCard({
    Key? key,
    required this.imageUrl,
    required this.isFront,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SwipeCard();
}

class _SwipeCard extends State<SwipeCard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) => widget.isFront ? buildFrontCard() : buildCard();

  Widget buildFrontCard() => GestureDetector(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final provider = Provider.of<CardProvider>(context, listen: true);
        final position = provider.position;
        final ms = provider.isDragging ? 0 : 400;

        final center = constraints.smallest.center(Offset.zero);

        final angle = provider.angle * pi / 180;
        final rotatedMatrix = Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..rotateZ(angle)
          ..translate(-center.dx, -center.dy);

        return AnimatedContainer(
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: ms),
          transform: rotatedMatrix..translate(position.dx, position.dy),
          child: buildCard()
        );
      },
    ),
    onPanStart: (details) {
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.startPosition(details);
    },
    onPanUpdate: (details) {
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.updatePosition(details);
    },
    onPanEnd: (details) {
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.endPosition();
    },
  );

  Widget buildCard() => ClipRRect(
    child: Container(
      margin: const EdgeInsets.fromLTRB(2, 10, 2, 0),
      decoration: BoxDecoration(
        color: const Color(0x8c8c8c8c),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(widget.imageUrl),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(20.00),
        child: Column(
          children: [
            Spacer(),
            buildState(),
            buildName()
          ],
        ),
      ),
    ),
  );

  Widget buildName() => Row(
    children: const [
      Flexible(
        child: Text(
          'Clubname', //TODO: Insert Clubname
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      SizedBox(width: 16),
      //TODO: Chiplist --> CustomChipList(values: , chipBuilder: chipBuilder)
    ],
  );

  Widget buildState() => Row(
    children: [
      Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        width: 12,
        height: 12,
      ),
      const SizedBox(width: 8),
      const Text('Open/Closed', style: TextStyle(color: Colors.white))
    ],
  );

}

class CardProvider extends ChangeNotifier {

  List<String> _images = [];

  bool _isDragging = false;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;
  double _angle = 0.00;

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
    resetPosition();
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0.00;
    notifyListeners();
  }

  void resetEntities() {
    _images = <String>[
      'assets/dummy-club.png',
      'assets/user_image.png',
      'assets/app-logo.png',
      'assets/dance-club.gif'
    ].reversed.toList();
    notifyListeners();
  }

}