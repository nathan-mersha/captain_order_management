import 'package:flutter/material.dart';

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 200,),
          Icon(
            Icons.code,
            color: Theme.of(context).primaryColor,
            size: 120,
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
}
