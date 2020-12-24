part of 'index.dart';

/// FlipX/FlipY
class Flip extends StatefulWidget {
  final bool y;
  final Widget child;
  final AnimationController controller;

  Flip(this.child, this.controller, {Key key, this.y = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _FlipState createState() => _FlipState();
}

class _FlipState extends State<Flip> {
  Animation<double> _rotate, _opacity;

  @override
  void initState() {
    super.initState();
    _rotate = Tween<double>(begin: 1.5, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.bounceOut));

    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .65)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform(
          alignment: Alignment.center,
          transform: widget.y
              ? (Matrix4.identity()..rotateY(_rotate.value))
              : (Matrix4.identity()..rotateX(_rotate.value)),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// Jello
class Jello extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Jello(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _JelloState createState() => _JelloState();
}

class _JelloState extends State<Jello> with SingleTickerProviderStateMixin {
  Animation<double> _rotate, _opacity;

  @override
  void initState() {
    super.initState();
    _rotate = Tween<double>(begin: 1.5, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.bounceOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .65)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(0, 0, _rotate.value + 1)
            ..rotateX(_rotate.value),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// Flash
class Flash extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Flash(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _FlashState createState() => _FlashState();
}

class _FlashState extends State<Flash> {
  Animation<double> _in1, _in2, _out1, _out2;

  @override
  void initState() {
    super.initState();
    _in1 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(.25, .5)));
    _in2 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(.75, 1)));
    _out1 = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .25)));
    _out2 = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(.5, .75)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Opacity(
          child: child,
          opacity: (widget.controller.value < .25)
              ? _out1.value
              : (widget.controller.value < .5)
                  ? _in1.value
                  : (widget.controller.value < .75)
                      ? _out2.value
                      : _in2.value,
        ),
      );
}

/// Pulse
class Pulse extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Pulse(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<Pulse> {
  Animation<double> _fore, _back;

  @override
  void initState() {
    super.initState();
    _fore = Tween<double>(begin: 1, end: 1.5).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0, .5, curve: Curves.easeOut)));
    _back = Tween<double>(begin: 1.5, end: 1).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(.5, 1, curve: Curves.easeIn)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.scale(
          child: child,
          scale: (widget.controller.value < .5) ? _fore.value : _back.value,
        ),
      );
}

/// Pulse
class Swing extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Swing(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _SwingState createState() => _SwingState();
}

class _SwingState extends State<Swing> {
  Animation<double> _rotate1, _rotate2, _rotate3, _rotate4, _rotate5, _rotate6;

  @override
  void initState() {
    super.initState();
    _rotate1 = Tween<double>(begin: 0, end: -.5).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0, 1 / 6, curve: Curves.easeOut)));
    _rotate2 = Tween<double>(begin: -.5, end: .5).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(1 / 6, 1 / 3, curve: Curves.easeInOut)));
    _rotate3 = Tween<double>(begin: .5, end: -.5).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(1 / 3, 1 / 2, curve: Curves.easeInOut)));
    _rotate4 = Tween<double>(begin: -.5, end: .4).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(1 / 2, 2 / 3, curve: Curves.easeInOut)));
    _rotate5 = Tween<double>(begin: .4, end: -.4).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(2 / 3, 5 / 6, curve: Curves.easeInOut)));
    _rotate6 = Tween<double>(begin: -.4, end: 0).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(5 / 6, 1, curve: Curves.easeOut)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.rotate(
          child: child,
          angle: _rotate1.value != -.5
              ? _rotate1.value
              : (_rotate2.value != .5)
                  ? _rotate2.value
                  : (_rotate3.value != -.5)
                      ? _rotate3.value
                      : (_rotate4.value != .4)
                          ? _rotate4.value
                          : (_rotate5.value != -.4)
                              ? _rotate5.value
                              : _rotate6.value,
        ),
      );
}

/// Spin
class Spin extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Spin(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _SpinState createState() => _SpinState();
}

class _SpinState extends State<Spin> {
  Animation<double> _spin;

  @override
  void initState() {
    super.initState();
    _spin = Tween<double>(begin: 0, end: 2).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) =>
            Transform.rotate(angle: _spin.value * pi, child: child),
      );
}

/// Dance
class Dance extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Dance(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _DanceState createState() => _DanceState();
}

class _DanceState extends State<Dance> {
  Animation<double> _step1, _step2, _step3;

  @override
  void initState() {
    super.initState();
    _step1 = Tween<double>(begin: 0, end: -.2).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0, 1 / 3, curve: Curves.bounceOut)));

    _step2 = Tween<double>(begin: -.2, end: .2).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(1 / 3, 2 / 3, curve: Curves.bounceOut)));

    _step3 = Tween<double>(begin: .2, end: 0).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(2 / 3, 1, curve: Curves.bounceOut)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform(
          child: child,
          alignment: Alignment.center,
          transform: Matrix4.skew(
            0,
            _step1.value != -0.2
                ? _step1.value
                : (_step2.value != 0.2)
                    ? _step2.value
                    : _step3.value,
          ),
        ),
      );
}

/// Zoom
class Zoom extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Zoom(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _ZoomState createState() => _ZoomState();
}

class _ZoomState extends State<Zoom> {
  Animation<double> _scale, _bounce, _opacity;

  @override
  void initState() {
    super.initState();
    _scale = Tween<double>(begin: 0, end: 1.2).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(.3, 1, curve: Curves.easeOut)));
    _bounce = Tween<double>(begin: 1.2, end: 1).animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(.3, 1, curve: Curves.elasticOut)));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .65)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.scale(
          scale: _scale.value == 1.2 ? _bounce.value : _scale.value,
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// Sheet
class Sheet extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Sheet(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _SheetState createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _offset = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _offset, child: widget.child);
}
