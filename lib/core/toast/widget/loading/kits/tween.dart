import 'dart:math' show sin, pi;
import 'package:flutter/animation.dart';

class DelayTween extends Tween<double> {
  final double delay;
  DelayTween({double begin, double end, this.delay})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => super.lerp((sin((t - delay) * 2 * pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
