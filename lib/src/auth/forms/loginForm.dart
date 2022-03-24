import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets.dart';
import '../formFields/index.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.email,
    required this.login,
    required this.forgotPassword,
    required this.setAuthStateToRegisterUser,
    //required this.setAuthStateToRegisterBusiness,
  });

  final String? email;
  final void Function(String email, String password, void Function() navigator) login;
  final void Function() forgotPassword;
  final void Function() setAuthStateToRegisterUser;
  //final void Function() setAuthStateToRegisterBusiness;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_LoginFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Login'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomTextField(
                  hint: "Email",
                  controller: _emailController,
                  onSaved: (input) {},
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: CustomTextField(
                  hint: "Password",
                  controller: _passwordController,
                  isHidden: _isPasswordHidden,
                  onSaved: (input) {},
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
                  child: CustomFormButton(
                    text: 'Log In',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.login(
                          _emailController.text,
                          _passwordController.text,
                          () => Navigator.pushNamed(context, '/home'),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          widget.forgotPassword();
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.setAuthStateToRegisterUser();
                        },
                        child: const Text(
                          'Register User Account ',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //widget.setAuthStateToRegisterUser();
                        },
                        child: const Text(
                          'Register Business Account ',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
        ),
      ],
    );
  }
}