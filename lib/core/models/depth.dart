import 'package:flutter/material.dart';

class DepthModel {
  double price, amount;

  DepthModel({
    @required this.price,
    @required this.amount,
  });

  factory DepthModel.fromJson(List<dynamic> json) => DepthModel(
        price: json[0],
        amount: json[1],
      );

  @override
  String toString() {
    return 'DepthModel {price: $price, amount: $amount}';
  }
}
