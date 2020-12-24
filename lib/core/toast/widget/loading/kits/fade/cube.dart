import 'dart:math';
import 'package:flutter/material.dart';
import '../tween.dart';

class KitFadeCube extends StatefulWidget {
  final Color color;
  final double size;

  KitFadeCube({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitFadeCubeState createState() => _KitFadeCubeState();
}

class _KitFadeCubeState extends State<KitFadeCube>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

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
        child: Center(
          child: Transform.rotate(
            angle: -45 * .0174533,
            child: Stack(
              children: List.generate(4, (i) {
                return Positioned.fill(
                  top: widget.size / 2,
                  left: widget.size / 2,
                  child: Transform.scale(
                    scale: 1 / sqrt2,
                    origin: Offset(-widget.size / 4, -widget.size / 4),
                    child: Transform(
                      transform: Matrix4.rotationZ(90 * i * .0174533),
                      child: Align(
                        alignment: Alignment.center,
                        child: FadeTransition(
                          opacity: DelayTween(begin: 0, end: 1, delay: .3 * i)
                              .animate(_controller),
                          child: SizedBox.fromSize(
                            size: Size.square(widget.size / 2),
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: widget.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
