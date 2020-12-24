import 'dart:math';
import 'package:flutter/material.dart';

class KitDualRing extends StatefulWidget {
  final Color color;
  final double size;

  KitDualRing({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitDualRingState createState() => _KitDualRingState();
}

class _KitDualRingState extends State<KitDualRing>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addListener(() => setState(() {}))
          ..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0, 1, curve: Curves.linear)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ((_animation.value) * pi * 2),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          child: SizedBox.fromSize(size: Size.square(widget.size - 5)),
          painter: _Painter(size: 5, color: widget.color),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Paint ring;
  final double angle;

  _Painter({this.angle = 90, double size, Color color})
      : ring = Paint()
          ..color = color
          ..strokeWidth = size
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect =
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0, _radian(angle), false, ring);
    canvas.drawArc(rect, _radian(180), _radian(angle), false, ring);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double _radian(double a) => pi / 180 * a;
}
