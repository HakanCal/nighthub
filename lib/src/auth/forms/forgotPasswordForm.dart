import 'package:flutter/material.dart';

import '../../widgets.dart';
import '../formFields/index.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    required this.email,
    required this.sendNewPassword,
    required this.setAuthStateToLoggedOut,
  });

  final String? email;
  final void Function(String email) sendNewPassword;
  final void Function() setAuthStateToLoggedOut;

  @override
  _ForgotPasswordForm createState() => _ForgotPasswordForm();
}

class _ForgotPasswordForm extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ForgotPasswordFormState');
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Reset Password'),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: CustomFormButton(
                    text: 'Send Email',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.sendNewPassword(_emailController.text);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: CustomFormButton(
                    text: 'Back to Login',
                    textColor: Colors.black,
                    fillColor: Colors.orange,
                    onPressed: () {
                      widget.setAuthStateToLoggedOut();
                      //Navigator.pop(context);
                    },
                  ),
                ),
                /*Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      StyledButton(
                        onPressed: () {
                          widget.sendNewPassword(_emailController.text);
                        },
                        child: const Text('SEND EMAIL'),
                      ),
                      StyledButton(
                        onPressed: () {
                          widget.setAuthStateToLoggedOut();
                          Navigator.pop(context);
                        },
                        child: const Text('SIGN IN'),
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ],
    );
  }
}
