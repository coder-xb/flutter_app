part of 'index.dart';

/// bounce
class Bounce extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Bounce(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _BounceState createState() => _BounceState();
}

class _BounceState extends State<Bounce> {
  Animation<double> _bounce, _offset;

  @override
  void initState() {
    super.initState();
    _bounce = Tween<double>(begin: -50, end: 0).animate(CurvedAnimation(
        curve: Interval(.35, 1, curve: Curves.bounceOut),
        parent: widget.controller));
    _offset = Tween<double>(begin: 0, end: -50).animate(CurvedAnimation(
        curve: Interval(0, .35, curve: Curves.easeInOut),
        parent: widget.controller));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.translate(
          child: child,
          offset:
              Offset(0, _offset.value == -50 ? _bounce.value : _offset.value),
        ),
      );
}

/// bounceUp/bounceDown
class BounceY extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  BounceY(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _BounceYState createState() => _BounceYState();
}

class _BounceYState extends State<BounceY> {
  Animation<double> _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _offset = Tween<double>(begin: widget.reverse ? -50 : 50, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.bounceOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .65)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// bounceLeft/bounceRight
class BounceX extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  BounceX(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _BounceXState createState() => _BounceXState();
}

class _BounceXState extends State<BounceX> {
  Animation<double> _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _offset = Tween<double>(begin: widget.reverse ? 50 : -50, end: 0).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.bounceOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .65)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.translate(
          offset: Offset(_offset.value, 0),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}
