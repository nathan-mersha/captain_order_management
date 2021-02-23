import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/customer/create_customer.dart';
import 'package:captain/page/customer/view_customer.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/statistics_expanded.dart';
import 'package:flutter/material.dart';

class StatisticsNormalOrderView extends StatefulWidget {
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  final GlobalKey<StatisticsNormalOrderViewState> statisticsCustomerKey;
  final GlobalKey<CustomerTableState> customerTableKey;

  const StatisticsNormalOrderView({this.customerTableKey, this.createCustomerKey, this.statisticsCustomerKey}) : super(key: statisticsCustomerKey);

  @override
  StatisticsNormalOrderViewState createState() => StatisticsNormalOrderViewState();
}

class StatisticsNormalOrderViewState extends State<StatisticsNormalOrderView> {
  // Product count
  int productTotal = 0;
  int productToday = 0;
  int productWeek = 0;
  int productMonth = 0;
  int productYear = 0;

  // Auto cryl
  int autoCrylTotal = 0;
  int autoCrylToday = 0;
  int autoCrylWeek = 0;
  int autoCrylMonth = 0;
  int autoCrylYear = 0;

  // Metalic
  int metalicTotal = 0;
  int metalicToday = 0;
  int metalicWeek = 0;
  int metalicMonth = 0;
  int metalicYear = 0;

  // Clear coat
  int clearCoatTotal = 0;
  int clearCoatToday = 0;
  int clearCoatWeek = 0;
  int clearCoatMonth = 0;
  int clearCoatYear = 0;

  @override
  void initState() {
    super.initState();
    getStat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        StatisticsExpandedCard(
          Statistics(title: "Product"),
          getTotalStat: productTotal,
          getTodayStat: productToday,
          getWeekStat: productWeek,
          getMonthStat: productMonth,
          getYearStat: productYear,
        ),
        StatisticsExpandedCard(
          Statistics(title: "Auto-Cryl"),
          getTotalStat: autoCrylTotal,
          getTodayStat: autoCrylToday,
          getWeekStat: autoCrylWeek,
          getMonthStat: autoCrylMonth,
          getYearStat: autoCrylYear,
        ),
        StatisticsExpandedCard(
          Statistics(title: "Metalic"),
          getTotalStat: metalicTotal,
          getTodayStat: metalicToday,
          getWeekStat: metalicWeek,
          getMonthStat: metalicMonth,
          getYearStat: metalicYear,
        ),
        StatisticsExpandedCard(
          Statistics(title: "Clear-Coat"),
          getTotalStat: clearCoatTotal,
          getTodayStat: clearCoatToday,
          getWeekStat: clearCoatWeek,
          getMonthStat: clearCoatMonth,
          getYearStat: clearCoatYear,
        ),
      ],
    );
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year;
  }

  bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    int durationDays = DateTime(dateTime.year, dateTime.month, dateTime.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    return durationDays >= -6;
  }

  bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.month == now.month && dateTime.year == now.year;
  }

  bool isThisYear(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year;
  }

  void getStat() async {
    // test values

    // Auto cryl
    autoCrylTotal = 0;
    autoCrylToday = 0;
    autoCrylWeek = 0;
    autoCrylMonth = 0;
    autoCrylYear = 0;

    // Auto cryl
    productTotal = 0;
    productToday = 0;
    productWeek = 0;
    productMonth = 0;
    productYear = 0;

    // Metalic
    metalicTotal = 0;
    metalicToday = 0;
    metalicWeek = 0;
    metalicMonth = 0;
    metalicYear = 0;

    // Clear coat
    clearCoatTotal = 0;
    clearCoatToday = 0;
    clearCoatWeek = 0;
    clearCoatMonth = 0;
    clearCoatYear = 0;

    List<NormalOrder> normalOrders = await NormalOrderDAL.find();

    normalOrders.forEach((NormalOrder normalOrder) {
      normalOrder.products.forEach((Product product) {
        if (product.type == CreateProductViewState.OTHER_PRODUCTS) {
          if (isToday(normalOrder.firstModified)) productToday++;
          if (isThisWeek(normalOrder.firstModified)) productWeek++;
          if (isThisMonth(normalOrder.firstModified)) productMonth++;
          if (isThisYear(normalOrder.firstModified)) productYear++;

          productTotal++;
        }

        if (product.paintType == CreateProductViewState.AUTO_CRYL) {
          if (isToday(normalOrder.firstModified)) autoCrylToday++;
          if (isThisWeek(normalOrder.firstModified)) autoCrylWeek++;
          if (isThisMonth(normalOrder.firstModified)) autoCrylMonth++;
          if (isThisYear(normalOrder.firstModified)) autoCrylYear++;

          autoCrylTotal++;
        } else if (product.paintType == CreateProductViewState.METALIC) {
          if (isToday(normalOrder.firstModified)) metalicToday++;
          if (isThisWeek(normalOrder.firstModified)) metalicWeek++;
          if (isThisMonth(normalOrder.firstModified)) metalicMonth++;
          if (isThisYear(normalOrder.firstModified)) metalicYear++;

          metalicTotal++;
        } else if (product.name.toLowerCase() == "clear coat" || product.name.toLowerCase() == "clear-coat") {
          if (isToday(normalOrder.firstModified)) clearCoatToday++;
          if (isThisWeek(normalOrder.firstModified)) clearCoatWeek++;
          if (isThisMonth(normalOrder.firstModified)) clearCoatMonth++;
          if (isThisYear(normalOrder.firstModified)) clearCoatYear++;

          clearCoatTotal++;
        }
      });
    });

    setState(() {});
  }
}
