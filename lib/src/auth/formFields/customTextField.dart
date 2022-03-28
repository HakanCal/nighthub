import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.hint,
    this.isHidden = false,
    required this.validator,
    required this.onSaved,
    required this.iconWidget,
    required this.textInputAction,
    required this.onFieldSubmitted
  });

  final FormFieldSetter<String> onSaved;
  final TextEditingController controller;
  final String hint;
  final bool isHidden;
  final FormFieldValidator<String> validator;
  final IconButton iconWidget;
  final TextInputAction textInputAction;
  final void Function(String) onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      obscureText: isHidden,
      controller: controller,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      decoration: InputDecoration(
        hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
        hintText: hint,
        contentPadding: const EdgeInsets.all(20.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(left: 30, right:10),
          child: iconWidget
        )
      ),
    );
  }
}