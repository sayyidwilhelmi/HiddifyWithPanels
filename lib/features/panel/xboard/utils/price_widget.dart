import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';


class PriceWidget extends StatelessWidget {
  final Plan plan;
  final String priceLabel;
  final String currency;

  PriceWidget(
      {required this.plan, required this.priceLabel, required this.currency});

  @override
  Widget build(BuildContext context) {
    final double? cheapestPrice = _findCheapestPrice(plan);

    return Text(
      '$priceLabel ${cheapestPrice != null ? cheapestPrice.toStringAsFixed(2) : 'N/A'} $currency',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  double? _findCheapestPrice(Plan plan) {
    final prices = [
      plan.monthPrice,
      plan.quarterPrice,
      plan.halfYearPrice,
      plan.yearPrice,
      plan.twoYearPrice,
      plan.threeYearPrice,
      plan.onetimePrice
    ].where((price) => price != null).toList();

    if (prices.isNotEmpty) {
      return prices.reduce((a, b) => a! < b! ? a : b);
    }
    return null;
  }
}
