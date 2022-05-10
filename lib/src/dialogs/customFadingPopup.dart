import 'package:flutter/material.dart';

class CustomPopup extends StatefulWidget {
  //Widget parameters
  const CustomPopup(
      {required this.text,
      required this.iconData,
      required this.startingColor,
      required this.fadingColor});

  final String text;
  final IconData iconData;
  final Color startingColor;
  final Color fadingColor;

  @override
  _CustomPopup createState() => _CustomPopup();
}

class _CustomPopup extends State<CustomPopup> {
  bool checkState = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        checkState = !checkState;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title: Text(widget.text, textAlign: TextAlign.center),
        content: Icon(widget.iconData,
            color: checkState ? widget.fadingColor : widget.startingColor,
            size: 40.00),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
  }
}

void showCustomFadingDialog(BuildContext context, String text,
    IconData iconData, Color startingColor, Color fadingColor) {
  showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pop(true);
        });
        return CustomPopup(
            text: text,
            iconData: iconData,
            startingColor: startingColor,
            fadingColor: fadingColor);
      });
}
