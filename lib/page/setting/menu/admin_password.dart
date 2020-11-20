import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPasswordSettings extends StatefulWidget {
  @override
  _AdminPasswordSettingsState createState() => _AdminPasswordSettingsState();
}

class _AdminPasswordSettingsState extends State<AdminPasswordSettings> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _mainPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  CSharedPreference cSharedPreference = CSharedPreference();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Text(
            "Change Admin Password",
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          color: Colors.black45,
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (nameValue) {
                    if (nameValue.isEmpty) {
                      return "Password must not be empty";
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  controller: _mainPasswordController,
                  decoration: InputDecoration(labelText: "Password", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  validator: (nameValue) {
                    if (nameValue.isEmpty) {
                      return "Please enter password again";
                    } else if (_mainPasswordController.text != _confirmPasswordController.text) {
                      clearInputs();
                      return "Password do not match";
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: "Confirm password", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                ),
                SizedBox(
                  height: 35,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlineButton(
                    child: Text(
                      "change password",
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        cSharedPreference.adminPassword = _mainPasswordController.text;
                        clearInputs();
                        CNotifications.showSnackBar(context, "Successfuly changed admin password", "success", () {}, backgroundColor: Colors.green);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void clearInputs() {
    _mainPasswordController.clear();
    _confirmPasswordController.clear();
  }
}
