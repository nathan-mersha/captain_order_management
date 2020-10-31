import 'package:flutter/material.dart';

class SystemLockedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SystemLockedPageState();
  }
}

class SystemLockedPageState extends State<SystemLockedPage> {
  static const String ERROR_PAGE = "ERROR_PAGE";
  static const String CONTACT_DEVELOPER = "CONTACT_DEVELOPER";
  String currentPage = ERROR_PAGE;

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
                        currentPage == ERROR_PAGE ? "Contact Developer" : "View Error",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    color: Colors.redAccent,
                    onPressed: () {
                      setState(() {
                        currentPage = currentPage == CONTACT_DEVELOPER ? ERROR_PAGE : CONTACT_DEVELOPER;
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

  Widget errorSecondaryPage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.whatshot,
            color: Colors.redAccent,
            size: 90,
          ),
          Text(
            "unknown error",
            style: TextStyle(color: Colors.black26),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Exception Occured",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "page is displayed if something is wrong",
            style: TextStyle(color: Colors.black38),
          ),
          FlatButton(child: Text("contact developer"),onPressed: (){
            setState(() {
              currentPage = CONTACT_DEVELOPER;
            });
          },)
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
    if (currentPage == ERROR_PAGE) {
      return errorSecondaryPage();
    } else {
      return developerSecondaryPage();
    }
  }
}
