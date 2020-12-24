import 'package:flutter/material.dart';

class ToastPosition {
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const ToastPosition(
      [this.alignment = Alignment.center, this.padding = EdgeInsets.zero]);

  static const top =
      ToastPosition(Alignment.topCenter, EdgeInsets.only(top: 75));
  static const center = ToastPosition(Alignment.center);
  static const bottom =
      ToastPosition(Alignment.bottomCenter, EdgeInsets.only(bottom: 30));
  static const topLeft =
      ToastPosition(Alignment.topLeft, EdgeInsets.only(top: 75, left: 20));
  static const topRight =
      ToastPosition(Alignment.topRight, EdgeInsets.only(top: 75, right: 20));
  static const centerLeft =
      ToastPosition(Alignment.centerLeft, EdgeInsets.only(left: 20));
  static const centerRight =
      ToastPosition(Alignment.centerLeft, EdgeInsets.only(right: 20));
  static const bottomLeft = ToastPosition(
      Alignment.centerLeft, EdgeInsets.only(bottom: 30, left: 20));
  static const bottomRight = ToastPosition(
      Alignment.centerLeft, EdgeInsets.only(bottom: 30, right: 20));
  static const notification = ToastPosition(Alignment(0, -.99));
}
