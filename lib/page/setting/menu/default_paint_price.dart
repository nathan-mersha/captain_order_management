import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';

class DefaultPaintPriceSettings extends StatefulWidget {
  @override
  _DefaultPaintPriceSettingsState createState() => _DefaultPaintPriceSettingsState();
}

class _DefaultPaintPriceSettingsState extends State<DefaultPaintPriceSettings> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _metalicPriceController = TextEditingController();
  TextEditingController _autoCrylPasswordController = TextEditingController();

  CSharedPreference cSharedPreference = CSharedPreference();

  @override
  void dispose() {
    super.dispose();
    _metalicPriceController.dispose();
    _autoCrylPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _metalicPriceController.text = cSharedPreference.metalicPricePerLitter.toStringAsFixed(2);
    _autoCrylPasswordController.text = cSharedPreference.autoCrylPricePerLitter.toStringAsFixed(2);

    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Text(
            "Set default paint prices",
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
                  validator: (metalicPriceValue) {
                    if (metalicPriceValue.isEmpty) {
                      return "Metalic price must not be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: _metalicPriceController,
                  decoration: InputDecoration(labelText: "Metalic Price", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  validator: (autoCrylValue) {
                    if (autoCrylValue.isEmpty) {
                      return "Auto-Cryl price must not be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: _autoCrylPasswordController,
                  decoration: InputDecoration(labelText: "Auto-Cryl Price", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                ),
                SizedBox(
                  height: 35,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlineButton(
                    child: Text(
                      "set",
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        cSharedPreference.metalicPricePerLitter = num.parse(_metalicPriceController.text);
                        cSharedPreference.autoCrylPricePerLitter = num.parse(_autoCrylPasswordController.text);

                        CNotifications.showSnackBar(context, "Successfuly changed paint prices", "success", () {}, backgroundColor: Colors.green);
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
}
