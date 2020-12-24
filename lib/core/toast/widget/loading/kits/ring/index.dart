import 'dart:math';
import 'package:flutter/material.dart';
export 'dual.dart';

class KitRing extends StatefulWidget {
  final Color color;
  final double size;

  KitRing({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitRingState createState() => _KitRingState();
}

class _KitRingState extends State<KitRing> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _anim1, _anim2, _anim3;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addListener(() => setState(() {}))
          ..repeat();
    _anim1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0, 1, curve: Curves.linear)));
    _anim2 = Tween<double>(begin: -2 / 3, end: 1 / 2).animate(CurvedAnimation(
        parent: _controller, curve: Interval(.5, 1, curve: Curves.linear)));
    _anim3 = Tween<double>(begin: .25, end: 5 / 6).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0, 1, curve: _Curve())));
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
        transform: Matrix4.identity()..rotateZ(_anim1.value * 5 * pi / 6),
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: Size.square(widget.size),
          child: CustomPaint(
            foregroundPainter: _Painter(
              width: 5,
              color: widget.color,
              progress: _anim3.value,
              angle: pi * _anim2.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Color color;
  final Paint _paint;
  final double width, angle, progress;

  _Painter({
    this.width,
    this.progress,
    this.angle,
    this.color = Colors.white,
  }) : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (min(size.width, size.height) - width) / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), angle,
        2 * pi * progress, false, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _Curve extends Curve {
  _Curve();

  @override
  double transform(double t) => (t <= .5) ? 2 * t : 2 * (1 - t);
}
