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
          SizedBox(
            height: 200,
          ),
          Image.asset(
            "assets/images/kelem_icon.png",
            scale: 1.5,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Kelem Designs",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "+251 912 27 0298",
            style: TextStyle(color: Colors.black45),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "kelem.designs@gmail.com",
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
