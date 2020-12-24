import 'dart:math';
import 'package:flutter/material.dart';

class KitHourglass extends StatefulWidget {
  final Color color;
  final double size;

  KitHourglass({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitHourglassState createState() => _KitHourglassState();
}

class _KitHourglassState extends State<KitHourglass>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _poure, _rotate;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200))
          ..addListener(() => setState(() {}))
          ..repeat();
    _poure = CurvedAnimation(parent: _controller, curve: Interval(0, .9))
      ..addListener(() => setState(() {}));
    _rotate = Tween<double>(begin: 0, end: 5).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(.9, 1, curve: Curves.fastOutSlowIn)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _rotate,
        child: SizedBox.fromSize(
          size: Size.square(widget.size * sqrt1_2),
          child: CustomPaint(
            painter: _Painter(poured: _poure.value, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final double poured;
  final Paint _paint, _powder;

  _Painter({this.poured, Color color = Colors.white})
      : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..color = color,
        _powder = Paint()
          ..style = PaintingStyle.fill
          ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width / 2,
        h = size.height / 2,
        hw = min(x * .8, h),
        gw = max(3, hw * .05),
        top = gw / 2,
        bottom = size.height - gw / 2;

    _paint.strokeWidth = gw;

    final Path hourglassPath = Path()
      ..moveTo(x - hw + 2, top)
      ..lineTo(x + hw, top)
      ..arcToPoint(
        Offset(x + hw, top + 7),
        radius: Radius.circular(4),
        clockwise: true,
      )
      ..lineTo(x + hw - 2, top + 8)
      ..quadraticBezierTo(x + hw - 2, (top + h) / 2 + 2, x + gw, h)
      ..quadraticBezierTo(x + hw - 2, (bottom + h) / 2, x + hw - 2, bottom - 7)
      ..arcToPoint(
        Offset(x + hw, bottom),
        radius: Radius.circular(4),
        clockwise: true,
      )
      ..lineTo(x - hw, bottom)
      ..arcToPoint(
        Offset(x - hw, bottom - 7),
        radius: Radius.circular(4),
        clockwise: true,
      )
      ..lineTo(x - hw + 2, bottom - 7)
      ..quadraticBezierTo(x - hw + 2, (bottom + h) / 2, x - gw, h)
      ..quadraticBezierTo(x - hw + 2, (top + h) / 2 + 2, x - hw + 2, top + 7)
      ..arcToPoint(
        Offset(x - hw, top),
        radius: Radius.circular(4),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(hourglassPath, _paint);

    final Path upperPart = Path()
      ..moveTo(0, top)
      ..addRect(Rect.fromLTRB(0, h * poured, size.width, h));
    canvas.drawPath(
        Path.combine(PathOperation.intersect, hourglassPath, upperPart),
        _powder);

    final Path lowerPartPath = Path()
      ..moveTo(x, bottom)
      ..relativeLineTo(hw * poured, 0)
      ..lineTo(x, bottom - poured * h - gw)
      ..lineTo(x - hw * poured, bottom)
      ..close();
    final Path lowerPart = Path.combine(
      PathOperation.intersect,
      lowerPartPath,
      Path()..addRect(Rect.fromLTRB(0, h, size.width, size.height)),
    );
    canvas.drawPath(lowerPart, _powder);

    canvas.drawLine(Offset(x, h), Offset(x, bottom), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
