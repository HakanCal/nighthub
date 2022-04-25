import 'dart:io';

import 'package:flutter/material.dart';

class EditEntityPage extends StatefulWidget {
  const EditEntityPage({
    Key? key,
    required this.userData,
    required this.profilePicture
  }) : super(key: key);

  final Map<String, dynamic> userData;
  final File? profilePicture;

  @override
  State<StatefulWidget> createState() => _EditEntityPage();
}

class _EditEntityPage extends State<EditEntityPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    ScrollController scroller = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Your site'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        controller: scroller,
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Column(
            children: <Widget> [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                          child: CustomImagePicker(
                            profilePicture: _profilePicture,
                            selectOrTakePhoto: selectOrTakePhoto,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: CustomTextField(
                              hint: 'Name Business',
                              controller: _entityNameController,
                              onSaved: (input) {
                                username = input!;
                              },
                              validator: (value) {
                                if(value!.isEmpty) {
                                  return 'Please username cannot be empty';
                                }
                                return null;
                              },
                              iconWidget: IconButton(
                                icon: const Icon(Icons.account_circle_rounded),
                                color: Colors.blueGrey,
                                onPressed: () {},
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus()
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: CustomTextField(
                            hint: 'Street name, Nr.',
                            controller: _streetController,
                            onSaved: (input) {},
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field cannot be empty';
                              }
                              return null;
                            },
                            iconWidget: IconButton(
                              icon: const Icon(Icons.house_rounded ),
                              color: Colors.blueGrey,
                              onPressed: () {},
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: CustomTextField(
                                    hint: 'Postcode',
                                    controller: _postCodeController,
                                    onSaved: (input) {},
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Empty field';
                                      }
                                      return null;
                                    },
                                    iconWidget: null,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                  ),
                                ),
                                Flexible(
                                  child: Padding (
                                    padding: const EdgeInsets.only(left: 40),
                                    child: CustomTextField(
                                      hint: 'Country',
                                      controller: _countryController,
                                      onSaved: (input) {},
                                      readOnly: true,
                                      validator: (value) {
                                        if (_postCodeController.text == '') {
                                          return '';
                                        }
                                        return null;
                                      },
                                      iconWidget: IconButton(
                                        icon: const Icon(Icons.arrow_drop_down ),
                                        color: Colors.blueGrey,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          renderCountryPicker(context);
                                        },
                                      ),
                                      onTap: () {
                                        renderCountryPicker(context);
                                      },
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          child: CustomDropdownField(
                            values: _interests,
                            hintText: 'Change interests',
                            options: options,
                            validator: (value) {
                              if (_interests.length < 3) {
                                return 'Please select at least 3 interests';
                              }
                              return null;
                            },
                            onChanged: onChangedInterest,
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            margin: const EdgeInsets.only(top: 10.0),
                            child: buildGridView(scroller)
                        ),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Row(
                              children: [
                                const Text(
                                  'Update Email',
                                  style: TextStyle(color: Colors.orange, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(_isUpdateEmail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                  color: Colors.orange,
                                  onPressed: () {
                                    setState(() {
                                      _isUpdateEmail = !_isUpdateEmail;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                        Container(
                            child: _isUpdateEmail ?
                            Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: CustomTextField(
                                      hint: 'New Email',
                                      controller: _emailController,
                                      onSaved: (input) {
                                        email = input!;
                                      },
                                      validator: (value) {
                                        if (_isUpdateEmail && value!.isEmpty) {
                                          return 'Please email cannot be empty';
                                        }
                                        return null;
                                      },
                                      iconWidget: IconButton(
                                        icon: const Icon(Icons.email),
                                        color: Colors.blueGrey,
                                        onPressed: () {},
                                      ),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    child: CustomTextField(
                                      hint: 'Current password',
                                      isHidden: true,
                                      controller: _currentPasswordController,
                                      onSaved: (input) {
                                        email = input!;
                                      },
                                      validator: (value) {
                                        if (_isUpdateEmail && value!.isEmpty) {
                                          return 'Please password cannot be empty';
                                        }
                                        return null;
                                      },
                                      iconWidget: IconButton(
                                        icon: const Icon(Icons.password_outlined),
                                        color: Colors.blueGrey,
                                        onPressed: () {},
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    ),
                                  ),
                                ]
                            ) : null
                        ),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Row(
                              children: [
                                const Text(
                                  'Update Password',
                                  style: TextStyle(color: Colors.orange, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(_isUpdatePassword ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                  color: Colors.orange,
                                  onPressed: () {
                                    setState(() {
                                      _isUpdatePassword = !_isUpdatePassword;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                        Container(
                            child: _isUpdatePassword ?
                            Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: CustomTextField(
                                      hint: 'New password',
                                      isHidden: _isPasswordHidden,
                                      controller: _newPasswordController,
                                      onSaved: (input) {
                                        email = input!;
                                      },
                                      validator: (value) {
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
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    ),
                                  ),
                                ]
                            ) : null
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          margin: const EdgeInsets.only(top: 10.0),
                          child: CustomFormButton(
                            text: 'Update',
                            textColor: Colors.black,
                            fillColor: Colors.orange,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                updateBusinessAccount(
                                    context,
                                    _entityNameController.text,
                                    _emailController.text,
                                    _streetController.text,
                                    _postCodeController.text,
                                    _countryController.text,
                                    _profilePicture,
                                    _interests,
                                        () => toggleLoader()
                                );
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          child: CustomFormButton(
                            text: 'Cancel',
                            textColor: Colors.orange,
                            fillColor: const Color(0xFF262626),
                            isLoading: false,
                            onPressed: isLoading ? null : () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        ],
      ),
    );

  }

}