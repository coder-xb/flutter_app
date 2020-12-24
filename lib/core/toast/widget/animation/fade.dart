part of 'index.dart';

/// Fade
class Fade extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Fade(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _FadeState createState() => _FadeState();
}

class _FadeState extends State<Fade> with SingleTickerProviderStateMixin {
  Animation<double> _animation, _opacity;

  @override
  void initState() {
    super.initState();
    _animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOut);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_animation);
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}

/// FadeUp/FadeDown
class FadeY extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  FadeY(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _FadeYState createState() => _FadeYState();
}

class _FadeYState extends State<FadeY> {
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
        builder: (BuildContext context, Widget child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// FadeLeft/FadeRight
class FadeX extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  FadeX(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _FadeXState createState() => _FadeXState();
}

class _FadeXState extends State<FadeX> {
  Animation<double> _animation, _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOut);
    _offset = Tween<double>(begin: widget.reverse ? 50 : -50, end: 0)
        .animate(_animation);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_animation);
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
