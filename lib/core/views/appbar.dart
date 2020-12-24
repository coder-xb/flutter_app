import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  final Color color;
  final double height;
  final Widget title, prefix, suffix;

  const MyAppBar({
    this.title,
    this.height = 44,
    this.color = Colors.white,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: height + MediaQuery.of(context).padding.top,
      color: color,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: title,
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: prefix,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: suffix,
            ),
          ),
        ],
      ),
    );
  }
}
