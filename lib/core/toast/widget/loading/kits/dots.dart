import 'package:flutter/material.dart';
import 'tween.dart';

class KitDots extends StatefulWidget {
  final Color color;
  final double size;

  KitDots({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitDotsState createState() => _KitDotsState();
}

class _KitDotsState extends State<KitDots> with SingleTickerProviderStateMixin {
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
        size: Size(widget.size * 1.5, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (i) => ScaleTransition(
              scale: DelayTween(begin: 0, end: 1, delay: i * .2)
                  .animate(_controller),
              child: SizedBox.fromSize(
                  size: Size.square(widget.size * .3),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: widget.color, shape: BoxShape.circle))),
            ),
          ),
        ),
      ),
    );
  }
}
