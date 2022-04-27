import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nighthub/src/auth/formFields/customChipList.dart';
import 'package:provider/provider.dart';

import 'cardProvider.dart';
import 'entity.dart';

class SwipeCard extends StatefulWidget {

  final Entity entity;
  final bool isFront;

  const SwipeCard({
    Key? key,
    required this.entity,
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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.fromLTRB(2, 10, 2, 0),
      decoration: BoxDecoration(
        color: const Color(0x8c8c8c8c),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: widget.entity.primaryImage,
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.fromLTRB(10.00, 0.00, 10.00, 30.00),
        child: Column(
          children: [
            const Spacer(),
            buildName()
          ],
        ),
      ),
    ),
  );

  Widget buildName() => Column(
    children: [
      Text(
        widget.entity.name,
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(0.00 , 2.00), blurRadius: 5.00)],
        ),
        textAlign: TextAlign.center,
      ),
      const Padding(padding: EdgeInsets.only(bottom: 5.00)),
      CustomChipList(
        values: widget.entity.tags,
        chipBuilder: (String value) {
          return Chip(
            label: Text(value),
            shadowColor: Colors.black54,
          );
        },
      ),
    ],
  );

}