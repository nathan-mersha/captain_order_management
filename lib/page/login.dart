import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
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
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

        RaisedButton(child: Text("Create"),onPressed: (){
          // todo : create
          Personnel employee = Personnel(type: Personnel.EMPLOYEE, phoneNumber: "0911234567", name: "Abebe Bekila",);
          Personnel customer = Personnel(type: Personnel.CUSTOMER, phoneNumber: "0911234567", name: "Chala Bekila",);
          Product paintOrder = Product(name: "paint", type: "paint", note: "Note");
          List<Product> otherProducts = [
            Product(name: "a", type: "paint", note: "Note"),
            Product(name: "b", type: "paint", note: "Note"),
          ];

//          NormalOrder normalOrder = NormalOrder(employee: employee, customer: customer, paintOrder: paintOrder, otherProducts: otherProducts);
          NormalOrder normalOrder = NormalOrder(advancePayment: 100);
          NormalOrderDAL.create(normalOrder).then((dynamic val){
            print("val --- $val");
          });

        },),

        RaisedButton(child: Text("Find"),onPressed: (){
          // todo : create
          NormalOrderDAL.find().then((List<NormalOrder> normalOrders){
            
            print(NormalOrder.toMapList(normalOrders));
          });

        },),

        RaisedButton(child: Text("Update"),onPressed: (){
          // todo : create

        },),

        RaisedButton(child: Text("Delete"),onPressed: (){
          // todo : create

        },),




      ],),),
    );
  }
}