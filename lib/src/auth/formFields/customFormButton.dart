import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomFormButton extends StatelessWidget {
  const CustomFormButton({
    required this.text,
    required this.textColor,
    required this.fillColor,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final Color textColor;
  final Color fillColor;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
        backgroundColor: onPressed != null
            ? MaterialStateProperty.all(fillColor)
            : MaterialStateProperty.all(fillColor.withOpacity(0.3)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                width: 2,
                color: Colors.orange,
              )),
        ),
      ),
      onPressed: onPressed,
      child: isLoading
          ? const SpinKitFadingCircle(
              color: Colors.black,
              size: 30,
            )
          : Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onPressed != null
                      ? textColor
                      : textColor.withOpacity(0.3),
                  fontSize: 16),
            ),
    );
  }
}
