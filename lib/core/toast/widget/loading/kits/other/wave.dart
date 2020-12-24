import 'package:flutter/material.dart';
import '../tween.dart';

enum KitWaveType { start, end, center }

class KitWave extends StatefulWidget {
  final Color color;
  final double size;
  final KitWaveType type;

  KitWave({
    Key key,
    this.color = Colors.white,
    this.size = 50,
    this.type = KitWaveType.start,
  })  : assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitWaveState createState() => _KitWaveState();
}

class _KitWaveState extends State<KitWave> with SingleTickerProviderStateMixin {
  int _count = 5;
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
    final List<double> bars = _delay(_count);
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 1.25, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            bars.length,
            (i) => ScaleWidget(
              scale: DelayTween(begin: .4, end: 1, delay: bars[i])
                  .animate(_controller),
              child: SizedBox.fromSize(
                  size: Size(widget.size / _count, widget.size),
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: widget.color))),
            ),
          ),
        ),
      ),
    );
  }

  List<double> _delay(int count) {
    switch (widget.type) {
      case KitWaveType.start:
        return _startDelay(count);
      case KitWaveType.end:
        return _endDelay(count);
      case KitWaveType.center:
      default:
        return _centerDelay(count);
    }
  }

  List<double> _startDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (i) => -1 - (i * .1) - .1).reversed,
      if (count.isOdd) -1,
      ...List<double>.generate(
          count ~/ 2, (i) => -1 + (i * .1) + (count.isOdd ? .1 : 0)),
    ];
  }

  List<double> _endDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (i) => -1 + (i * .1) + .1).reversed,
      if (count.isOdd) -1,
      ...List<double>.generate(
          count ~/ 2, (i) => -1 - (i * .1) - (i.isOdd ? .1 : 0)),
    ];
  }

  List<double> _centerDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (i) => -1 + (i * .2) + .2).reversed,
      if (count.isOdd) -1,
      ...List<double>.generate(count ~/ 2, (i) => -1 + (i * .2) + .2)
    ];
  }
}

class ScaleWidget extends AnimatedWidget {
  final Widget child;
  final Alignment alignment;

  ScaleWidget({
    Key key,
    @required Animation<double> scale,
    @required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key, listenable: scale);

  Animation<double> get scale => listenable;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scale(1.0, scale.value, 1),
      alignment: alignment,
      child: child,
    );
  }
}
