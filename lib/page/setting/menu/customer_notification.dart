import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:flutter/material.dart';

class CustomerNotificationSettings extends StatefulWidget {
  @override
  _CustomerNotificationSettingsState createState() => _CustomerNotificationSettingsState();
}

class _CustomerNotificationSettingsState extends State<CustomerNotificationSettings> {
  CSharedPreference cSharedPreference = CSharedPreference();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            child: Text(
              "Customer Notifications",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            color: Colors.black45),
        SizedBox(
          height: 40,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Switch(
                        value: cSharedPreference.sendNotificationAutomatically,
                        onChanged: (bool) {
                          setState(() {
                            cSharedPreference.sendNotificationAutomatically = bool;
                          });
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Enable automatic notification",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "If customer notification is enabled, customers will receive automatic notification via sms when paint order is completed",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
