import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/analysis/stats/order/normal_order.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class Exporter {
  final oCCy = NumberFormat("#,##0.00", "en_US");

  Document pdf = Document();

  TextStyle companyValuesStyle() {
    return TextStyle(color: PdfColors.black, fontSize: 12, );
  }

  TextStyle getValueStyle() {
    return TextStyle(color: PdfColor.fromInt(0xff404040), fontSize: 16, );
  }

  TextStyle getTableTitleStyle() {
    return TextStyle(fontSize: 20, fontWeight: FontWeight.bold, );
  }

  TextStyle getTitleStyle() {
    return TextStyle(fontSize: 13, lineSpacing: 10, fontWeight: FontWeight.bold, color: PdfColor.fromInt(0xff404040));
  }

  Future<bool> toPdf(
      {Personnel customer,
      List<Product> products,
      num totalAmount,
      num advanceAmount,
      num remainingAmount,
      DateTime lastModified,
      mat.BuildContext context}) async {


    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        build: (Context context) {
          return Container(
            child: Column(
              children: <Widget>[
                // Kapci company information
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20), //40
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Kapci Coatings",
                              style: TextStyle(
                                fontSize: 19,
                              )),
                          Text("Address : Gofa , Addis Ababa", style: companyValuesStyle(), textAlign: TextAlign.right),
                          Text("Tel : +251911780428", style: companyValuesStyle()),
                          Text("www.kemsadhub.com", style: companyValuesStyle()),
                          Text(DateFormat.yMMMd().format(lastModified), style: companyValuesStyle()),
                        ],
                      )
                    ],
                  ),
                ),

                Divider(),
                SizedBox(height: 20),
                Align(
                    child: Text("Customer", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(children: [
                  TableRow(children: [Text("Name"), Text(customer.name)]),
                  TableRow(children: [Text("Phone number"), Text(customer.phoneNumber)]),
                  TableRow(children: [Text("Address"), Text(customer.address ?? "-")]),
                  TableRow(children: [Text("Address Detail"), Text(customer.addressDetail ?? "-")]),
                  TableRow(children: [Text("Email"), Text(customer.email ?? "-")])
                ]),

                SizedBox(height: 28),
                Align(
                    child: Text("Products", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(border: TableBorder(color: PdfColor.fromInt(0xffbfbfbf)), children: createProductRow(products,)),
                SizedBox(height: 28),
                Align(
                    child: Text("Payment", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(children: [
                  TableRow(children: [
                    Text("Total"),
                    Text("${oCCy.format(totalAmount ?? 0)} br", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ]),
                  TableRow(children: [
                    Text("Advance"),
                    Text("${oCCy.format(advanceAmount ?? 0)} br", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ]),
                  TableRow(children: [
                    Text("Remaining"),
                    Text("${oCCy.format(remainingAmount ?? 0)} br", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ]),
                ]),

                // Content
              ],
            ),
          );
        }));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    return true;
  }




  Future<bool> toPdfProductSold({
        List<ProductSoldStat> productSoldStat,
        DateTime from,
        DateTime to,
        mat.BuildContext context}) async {

    DateFormat dateFormat = DateFormat("dd-MMM-yyyy");

    print("to pdf product sold : $productSoldStat");

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        build: (Context context) {
          return Container(
            child: Column(
              children: <Widget>[
                // Kapci company information
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20), //40
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Kapci Coatings",
                              style: TextStyle(
                                fontSize: 19,

                              )),
                          Text("Address : Gofa , Addis Ababa", style: companyValuesStyle(), textAlign: TextAlign.right),
                          Text("Tel : +251911780428", style: companyValuesStyle()),
                          Text("www.kemsadhub.com", style: companyValuesStyle()),
                          Text(DateFormat.yMMMd().format(DateTime.now()), style: companyValuesStyle()),
                        ],
                      )
                    ],
                  ),
                ),

                Divider(),
                SizedBox(height: 20),
                Align(
                    child: Text("Time range", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(children: [
                  TableRow(children: [Text("From"), Text(dateFormat.format(from))]),
                  TableRow(children: [Text("To"), Text(dateFormat.format(to))]),

                ]),

                SizedBox(height: 8),
                Align(
                    child: Text("Normal Orders", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(border: TableBorder(color: PdfColor.fromInt(0xffbfbfbf)), children: createProductSoldStat(productSoldStat)),
                SizedBox(height: 28),
                Align(
                    child: Text("Payment", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),

                Table(children: [
                  TableRow(children: [
                    Text("Total"),
                    Text("${getSum(productSoldStat)} br", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ]),
                ]),

                // Content
              ],
            ),
          );
        }));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    return true;
  }

  String getSum(List<ProductSoldStat> productSoldStats){
    num sum = 0;
    productSoldStats.forEach((ProductSoldStat element) {
      sum = element.totalAmount + sum;
    });
    return sum.toStringAsFixed(2);
  }

  List<TableRow> createProductRow(List<Product> products) {
    List<TableRow> tableRow = [];

    tableRow.add(TableRow(children: [
      Text("Name", style: getTitleStyle()),
      Text("Type", style: getTitleStyle()),
      Text("Paint type", style: getTitleStyle()),
      Text("Quantity", style: getTitleStyle()),
      Text("Unit", style: getTitleStyle()),
      Text("SubTotal", style: getTitleStyle()),
      Text("Status", style: getTitleStyle()),
    ]));

    tableRow.addAll(products.map((Product p) {
      return TableRow(children: [
        Text(p.name),
        Text(p.type ?? "-"),
        Text(p.paintType ?? "-"),
        Text("${p.quantityInCart.toString()}${p.unitOfMeasurement}"),
        Text("${oCCy.format(p.unitPrice)}br"),
        Text("${oCCy.format(p.subTotal)}br"),
        Text(p.status ?? "-"),
      ]);
    }).toList());

    return tableRow;
  }

  List<TableRow> createProductSoldStat(List<ProductSoldStat> productsSold) {
    List<TableRow> tableRow = [];

    tableRow.add(TableRow(children: [
      Text("Name", style: getTitleStyle()),
      Text("Paint type", style: getTitleStyle()),
      Text("Count", style: getTitleStyle()),
      Text("Quantity", style: getTitleStyle()),
      Text("Total", style: getTitleStyle()),
      Text("Unit Price", style: getTitleStyle()),
    ]));

    tableRow.addAll(productsSold.map((ProductSoldStat productSoldStat) {
      // print(productSoldStat.product.name);
      return TableRow(children: [
        Text(ascii.decode(productSoldStat.product.name.codeUnits)),
        Text(productSoldStat.product.type ?? "-"),
        Text(productSoldStat.count.toString() ?? "-"),
        Text(productSoldStat.quantity.toString() ?? "-"),
        Text(productSoldStat.totalAmount.toString() ?? "-"),
        Text(productSoldStat.product.unitPrice.toString() ?? "-"),

      ]);
    }).toList());

    return tableRow;
  }
}
