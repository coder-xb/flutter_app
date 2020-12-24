import 'package:flutter/material.dart';
import '../tween.dart';

class KitFadeCircle extends StatefulWidget {
  final Color color;
  final double size;

  KitFadeCircle({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitFadeCircleState createState() => _KitFadeCircleState();
}

class _KitFadeCircleState extends State<KitFadeCircle>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final List<double> _delays = [
    0,
    -1.1,
    -1,
    -.9,
    -.8,
    -.7,
    -.6,
    -.5,
    -.4,
    -.3,
    -.2,
    -.1
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: List.generate(
            12,
            (index) => Positioned.fill(
              left: widget.size / 2,
              top: widget.size / 2,
              child: Transform(
                transform: Matrix4.rotationZ(30 * index * .0174533),
                child: Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: DelayTween(begin: 0, end: 1, delay: _delays[index])
                        .animate(_controller),
                    child: SizedBox.fromSize(
                      size: Size.square(widget.size * .15),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: widget.color, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
