import 'dart:typed_data';
import 'dart:ui';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class Exporter {
  final oCCy = NumberFormat("#,##0.00", "en_US");

  Document pdf = Document();

  TextStyle companyValuesStyle(ttf) {
    return TextStyle(color: PdfColors.black, fontSize: 12, font: ttf);
  }

  TextStyle getValueStyle(ttf) {
    return TextStyle(color: PdfColor.fromInt(0xff404040), fontSize: 16, font: ttf);
  }

  TextStyle getTableTitleStyle(ttf) {
    return TextStyle(fontSize: 20, fontWeight: FontWeight.bold, font: ttf);
  }

  TextStyle getTitleStyle(ttf) {
    return TextStyle(fontSize: 13, lineSpacing: 10, fontWeight: FontWeight.bold, font: ttf);
  }

  Future<bool> toPdf(
      {Personnel customer,
      List<Product> products,
      num totalAmount,
      num advanceAmount,
      num remainingAmount,
      DateTime lastModified,
      mat.BuildContext context}) async {
    ByteData data = await rootBundle.load('assets/fonts/Nunito-Bold.ttf');
    var ttf = Font.ttf(data);

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
                                font: ttf,
                              )),
                          Text("Address : Gofa , Addis Ababa", style: companyValuesStyle(ttf), textAlign: TextAlign.right),
                          Text("Tel : +251911780428", style: companyValuesStyle(ttf)),
                          Text("www.kemsadhub.com", style: companyValuesStyle(ttf)),
                          Text(DateFormat.yMMMd().format(lastModified), style: companyValuesStyle(ttf)),
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

                Table(border: TableBorder(color: PdfColor.fromInt(0xffbfbfbf)), children: createProductRow(products, ttf)),
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

  List<TableRow> createProductRow(List<Product> products, var ttf) {
    List<TableRow> tableRow = [];

    tableRow.add(TableRow(children: [
      Text("Name", style: getTitleStyle(ttf)),
      Text("Type", style: getTitleStyle(ttf)),
      Text("Paint type", style: getTitleStyle(ttf)),
      Text("Quantity", style: getTitleStyle(ttf)),
      Text("Unit", style: getTitleStyle(ttf)),
      Text("SubTotal", style: getTitleStyle(ttf)),
      Text("Status", style: getTitleStyle(ttf)),
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
}
