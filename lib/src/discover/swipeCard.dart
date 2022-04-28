import 'dart:math';
import 'package:flutter/material.dart';

import 'package:nighthub/src/auth/formFields/customChipList.dart';
import 'entity.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({
    Key? key,
    required this.entity,
    required this.isFront,
    required this.setScreenSize,
    required this.position,
    required this.isDragging,
    required this.angle,
    required this.startPosition,
    required this.updatePosition,
    required this.endPosition,
  }) : super(key: key);

  final Entity entity;
  final bool isFront;
  final Function(Size size) setScreenSize;
  final Offset position;
  final bool isDragging;
  final double angle;
  final void Function(DragStartDetails details) startPosition;
  final void Function(DragUpdateDetails details) updatePosition;
  final void Function() endPosition;

  @override
  State<StatefulWidget> createState() => _SwipeCard();
}

class _SwipeCard extends State<SwipeCard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      widget.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) => widget.isFront ? buildFrontCard() : buildCard();

  Widget buildFrontCard() => GestureDetector(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final position = widget.position;
        final ms = widget.isDragging ? 0 : 400;

        final center = constraints.smallest.center(Offset.zero);

        final angle = widget.angle * pi / 180;
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
      widget.startPosition(details);
    },
    onPanUpdate: (details) {
      widget.updatePosition(details);
    },
    onPanEnd: (details) {
      widget.endPosition();
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
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
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
        widget.entity.username,
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 5)],
        ),
        textAlign: TextAlign.center,
      ),
      const Padding(padding: EdgeInsets.only(bottom: 5)),
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