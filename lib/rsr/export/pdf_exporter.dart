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
    ByteData data = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
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
                  TableRow(children: [Text("Name"), Text(customer.name, style: getTitleStyle(ttf))]),
                  TableRow(children: [Text("Phone number"), Text(customer.phoneNumber, style: getTitleStyle(ttf))]),
                  TableRow(children: [Text("Address"), Text(customer.address ?? "-", style: getTitleStyle(ttf))]),
                  TableRow(children: [Text("Address Detail"), Text(customer.addressDetail ?? "-", style: getTitleStyle(ttf))]),
                  TableRow(children: [Text("Email"), Text(customer.email ?? "-", style: getTitleStyle(ttf))])
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




  Future<bool> toPdfProductSold({
    List<ProductSoldStat> productSoldStat,
    DateTime from,
    DateTime to,
    mat.BuildContext context}) async {
    ByteData data = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
    // final Uint8List fontDataBold = File('open-sans-bold.ttf').readAsBytesSync();
    // final Font ttfBold = Font.ttf(fontData.buffer.asByteData());

    var ttf = Font.ttf(data);
    DateFormat dateFormat = DateFormat("dd-MMM-yyyy");



    int maxElement = 25;
    if(productSoldStat.length <= maxElement){
      print("Here it's less than");
      createPageSoldProduct(ttf, dateFormat, from, to, productSoldStat, 0, productSoldStat.length);
    }else{
      int firstIndex = 0;
      int lastIndex = 0;
      bool done = false;
      print("product length : ${productSoldStat.length}-------------");
      while(!done){
        print("Here looping");
        firstIndex = lastIndex;
        lastIndex = lastIndex + maxElement;
        if(lastIndex > productSoldStat.length){
          lastIndex = productSoldStat.length;
          done = true;
        }
        createPageSoldProduct(ttf, dateFormat, from, to, productSoldStat, firstIndex, lastIndex);
      }

    }
   

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    return true;
  }

  void createPageSoldProduct(Font ttf, DateFormat dateFormat, DateTime from, DateTime to, List<ProductSoldStat> productSoldStat, int start, int end) {
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
                          Text(DateFormat.yMMMd().format(DateTime.now()), style: companyValuesStyle(ttf)),
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
    
                SizedBox(height: 28),
                Align(
                    child: Text("Orders", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.centerLeft),
                SizedBox(height: 8),
    
                Table(border: TableBorder(color: PdfColor.fromInt(0xffbfbfbf)), children: createProductSoldStat(productSoldStat.sublist(start,end), ttf)),
                SizedBox(height: 28),

                SizedBox(height: 8),
    
                end == productSoldStat.length ? Table(children: [
                  TableRow(children: [
                    Text("Total"),
                    Text("${getSum(productSoldStat)} br", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ]),
                ]) : Container(),
    
                // Content
              ],
            ),
          );
        }));
  }

  String getSum(List<ProductSoldStat> productSoldStats){
    num sum = 0;
    productSoldStats.forEach((ProductSoldStat element) {
      sum = element.totalAmount + sum;
    });
    return sum.toStringAsFixed(2);
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
        Text(p.name, style: getTitleStyle(ttf)),
        Text(p.type ?? "-", style: getTitleStyle(ttf)),
        Text(p.paintType ?? "-", style: getTitleStyle(ttf)),
        Text("${p.quantityInCart.toString()}${p.unitOfMeasurement}", style: getTitleStyle(ttf)),
        Text("${oCCy.format(p.unitPrice)} br", style: getTitleStyle(ttf)),
        Text("${oCCy.format(p.subTotal)} br", style: getTitleStyle(ttf)),
        Text(mapStatus(p.status) ?? "-", style: getTitleStyle(ttf)),
      ]);
    }).toList());

    return tableRow;
  }
  String mapStatus(String old){
    if(old == "c_Delivered"){
      return "Delivered";
    }else if(old == "b_Completed"){
      return "Completed";
    }else{
      return "Pending";
    }
  }

  List<TableRow> createProductSoldStat(List<ProductSoldStat> productsSold, var ttf) {
    List<TableRow> tableRow = [];

    tableRow.add(TableRow(children: [
      Text("Name", style: getTitleStyle(ttf)),
      Text("Paint type", style: getTitleStyle(ttf)),
      Text("Count", style: getTitleStyle(ttf)),
      Text("Quantity", style: getTitleStyle(ttf)),
      Text("Total", style: getTitleStyle(ttf)),
      Text("Unit Price", style: getTitleStyle(ttf)),
    ]));


    tableRow.addAll(productsSold.map((ProductSoldStat productSoldStat) {
      return TableRow(children: [
        Text(productSoldStat.product.name, style: getTitleStyle(ttf)),
        Text(productSoldStat.product.type ?? "-", style: getTitleStyle(ttf)),
        Text(productSoldStat.count.toString() ?? "-", style: getTitleStyle(ttf)),
        Text(productSoldStat.quantity.toString() ?? "-", style: getTitleStyle(ttf)),
        Text(productSoldStat.totalAmount.toString() ?? "-", style: getTitleStyle(ttf)),
        Text(productSoldStat.product.unitPrice.toString() ?? "-", style: getTitleStyle(ttf)),
      ]);
    }).toList());

    return tableRow;
  }
}
