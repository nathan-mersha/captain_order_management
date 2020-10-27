import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      drawer: Menu.getSideDrawer(context),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(child: Text("Login page"),),
    );
  }
}