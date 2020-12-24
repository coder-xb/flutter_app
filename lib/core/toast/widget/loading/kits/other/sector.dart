import 'dart:math';
import 'package:flutter/material.dart';

class KitSector extends StatefulWidget {
  final Color color;
  final double size;

  KitSector({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitSectorState createState() => _KitSectorState();
}

class _KitSectorState extends State<KitSector>
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
    _animation = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0, 1, curve: Curves.easeOut)));
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
        transform: Matrix4.identity()..rotateZ((_animation.value) * pi),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          child: SizedBox.fromSize(size: Size.square(widget.size)),
          painter: _Painter(color: widget.color),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Paint glass;
  final double weight;

  _Painter({this.weight = 90.0, Color color = Colors.white})
      : glass = Paint()
          ..color = color
          ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0, _radian(weight), true, glass);
    canvas.drawArc(rect, _radian(180), _radian(weight), true, glass);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double _radian(double a) => pi / 180 * a;
}
