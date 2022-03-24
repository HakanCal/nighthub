import 'package:flutter/material.dart';

class CustomFormButton extends StatelessWidget {
  const CustomFormButton({
    required this.text,
    required this.textColor,
    required this.fillColor,
    required this.onPressed,
  });

  final String text;
  final Color textColor;
  final Color fillColor;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
        backgroundColor: MaterialStateProperty.all(fillColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                color: Colors.orange,
                width: 2,
              )
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 16
        ),
      ),
    );
  }
}