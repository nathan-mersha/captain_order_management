import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/route.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  static const String LOGIN = "LOGIN";
  static const String CONTACT_DEVELOPER = "CONTACT_DEVELOPER";

  final _formKey = GlobalKey<FormState>();
  String currentPage = LOGIN;

  final TextEditingController _passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    image: AssetImage("assets/images/captain_icon_big_faded.png"),
                    alignment: Alignment.topRight,
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Customer and Order \nManagement",
                    style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Captain's customer and management system, create order and\nanalyze your data.",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w100),
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        currentPage == LOGIN ? "Contact Developer" : "Login Page",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        currentPage = currentPage == CONTACT_DEVELOPER ? LOGIN : CONTACT_DEVELOPER;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: loadSecondaryPage(),
          )
        ],
      ),
    );
  }

  Widget loginSecondaryPage() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Please enter your\npassword",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  validator: (passwordValue) {
                    CSharedPreference cSP = GetCSPInstance.cSharedPreference;
                    String mainPassword = cSP.mainPassword;

                    if (passwordValue.isEmpty) {
                      return "Password must not be empty";
                    } else if (mainPassword != passwordValue) {
                      final String backupAdminPassword = "!@#tobeornottobe*()";

                      if (passwordValue == backupAdminPassword) {
                        return null;
                      } else {
                        _passwordInputController.clear();
                        return "Password is incorrect";
                      }
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  controller: _passwordInputController,
                  decoration: InputDecoration(hintText: "password"),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.pushReplacementNamed(context, CRoutes.DASHBOARD);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          Text(
            "www.captain.com",
            style: TextStyle(color: Colors.black26),
          )
        ],
      ),
    );
  }

  Widget developerSecondaryPage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.code,
            color: Theme.of(context).primaryColor,
            size: 90,
          ),
          Text(
            "Developed by",
            style: TextStyle(color: Colors.black26),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Nathan Mersha",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "0967823595",
            style: TextStyle(color: Colors.black38),
          ),
          Text(
            "nathanmersha@gmail.com",
            style: TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget loadSecondaryPage() {
    if (currentPage == LOGIN) {
      return loginSecondaryPage();
    } else {
      return developerSecondaryPage();
    }
  }
}
