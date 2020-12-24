import 'package:flutter/material.dart';

/// [文本提示]Toast
class TextToast extends StatefulWidget {
  final String text;
  final Color color;
  final double radius;
  final TextStyle style;
  final EdgeInsetsGeometry padding;

  TextToast(
    this.text, {
    Key key,
    this.radius = 10,
    this.color = Colors.black54,
    this.padding = const EdgeInsets.fromLTRB(15, 5, 15, 7),
    this.style = const TextStyle(fontSize: 14, color: Colors.white),
  }) : super(key: key);

  @override
  _TextToastState createState() => _TextToastState();
}

class _TextToastState extends State<TextToast> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        constraints:
            constraints.copyWith(maxWidth: constraints.biggest.width - 40),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: Text(
          widget.text,
          style:
              TextStyle(fontSize: 14, color: Colors.white).merge(widget.style),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
