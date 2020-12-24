part of 'index.dart';

/// SlideUp/SlideDown
class SlideY extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  SlideY(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _SlideYState createState() => _SlideYState();
}

class _SlideYState extends State<SlideY> {
  Animation<double> _animation, _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOut);
    _offset = Tween<double>(begin: widget.reverse ? -50 : 50, end: 0)
        .animate(_animation);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_animation);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) =>
            Transform.translate(offset: Offset(0, _offset.value), child: child),
      );
}

/// SlideLeft/SlideRight
class SlideX extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  SlideX(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _SlideXState createState() => _SlideXState();
}

class _SlideXState extends State<SlideX> {
  Animation<double> _animation, _offset;

  @override
  void initState() {
    super.initState();
    _animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOut);
    _offset = Tween<double>(begin: widget.reverse ? 50 : -50, end: 0)
        .animate(_animation);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) =>
            Transform.translate(offset: Offset(_offset.value, 0), child: child),
      );
}
