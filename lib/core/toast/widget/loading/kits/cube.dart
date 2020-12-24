import 'dart:math';
import 'package:flutter/material.dart';

class KitFoldCube extends StatefulWidget {
  final Color color;
  final double size;

  KitFoldCube({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitFoldCubeState createState() => _KitFoldCubeState();
}

class _KitFoldCubeState extends State<KitFoldCube>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _rotate1, _rotate2, _rotate3, _rotate4;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200))
          ..addListener(() => setState(() {}))
          ..repeat(reverse: true);
    _rotate1 = Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0, .25, curve: Curves.easeIn)));
    _rotate2 = Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
        parent: _controller, curve: Interval(.25, .5, curve: Curves.easeIn)));
    _rotate3 = Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
        parent: _controller, curve: Interval(.5, .75, curve: Curves.easeIn)));
    _rotate4 = Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
        parent: _controller, curve: Interval(.75, 1, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(widget.size),
      child: Center(
        child: SizedBox.fromSize(
          size: Size.square(widget.size / sqrt2),
          child: Center(
            child: Transform.rotate(
              angle: -45 * 0.0174533,
              child: Stack(
                children: <Widget>[
                  _view(_rotate2, 0),
                  _view(_rotate3, 1),
                  _view(_rotate4, 2),
                  _view(_rotate1, 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _view(Animation<double> rotat, int i) => Positioned.fill(
        top: widget.size / sqrt2 / 2,
        left: widget.size / sqrt2 / 2,
        child: Transform(
          transform: Matrix4.rotationZ(90 * i * .0174533),
          child: Align(
            alignment: Alignment.center,
            child: Transform(
              transform: Matrix4.identity()..rotateY(rotat.value * .0174533),
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: 1 - (rotat.value / 180),
                child: SizedBox.fromSize(
                  size: Size.square(widget.size / sqrt2 / 2),
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: widget.color)),
                ),
              ),
            ),
          ),
        ),
      );
}
