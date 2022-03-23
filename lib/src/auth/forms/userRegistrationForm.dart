import 'package:flutter/material.dart';

import '../../widgets.dart';
import '../formFields/index.dart';

class UserRegisterForm extends StatefulWidget {
  const UserRegisterForm({
    required this.registerAccount,
    required this.cancel,
    required this.email,
  });

  final String? email;
  final void Function(
      String email,
      String username,
      String password
  ) registerAccount;
  final void Function() cancel;

  @override
  _UserRegisterFormState createState() => _UserRegisterFormState();
}

class _UserRegisterFormState extends State<UserRegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: "Username",
                    controller: _usernameController,
                    onSaved: (input) {
                      print('saved');
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please username cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.account_circle_rounded),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: "Email",
                    controller: _emailController,
                    onSaved: (input) {
                      print('saved');
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please email cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.email),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    hint: "Password",
                    controller: _passwordController,
                    isHidden: _isPasswordHidden,
                    onSaved: (input) {
                      print('saved');
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please password cannot be empty';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: _isPasswordHidden ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                      color: Colors.blueGrey,
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomTextField(
                    hint: "Confirm password",
                    controller: _confirmPasswordController,
                    isHidden: true,
                    onSaved: (input) {
                      print('saved');
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Passwords should match';
                      }
                      return null;
                    },
                    iconWidget: IconButton(
                      icon: const Icon(Icons.password_rounded ),
                      color: Colors.blueGrey,
                      onPressed: () {},
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: CustomFormButton(
                    text: 'Cancel',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: widget.cancel,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomFormButton(
                    text: 'Create',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.registerAccount(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                      //Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}