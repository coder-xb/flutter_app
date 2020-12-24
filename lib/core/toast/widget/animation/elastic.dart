part of 'index.dart';

/// Elastic
class Elastic extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  Elastic(this.child, this.controller, {Key key})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _ElasticState createState() => _ElasticState();
}

class _ElasticState extends State<Elastic> {
  Animation<double> _bounce, _opacity;

  @override
  void initState() {
    super.initState();
    _bounce = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.elasticOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .45)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.scale(
          scale: _bounce.value,
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// ElasticUp/ElasticDown
class ElasticY extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  ElasticY(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _ElasticYState createState() => _ElasticYState();
}

class _ElasticYState extends State<ElasticY> {
  Animation<double> _bounce, _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _offset = Tween<double>(
            begin: widget.reverse ? -50 : 50, end: widget.reverse ? 20 : -20)
        .animate(CurvedAnimation(
            parent: widget.controller,
            curve: Interval(.3, 1, curve: Curves.easeOut)));
    _bounce = Tween<double>(begin: widget.reverse ? 20 : -20, end: 0).animate(
        CurvedAnimation(
            parent: widget.controller,
            curve: Interval(.3, 1, curve: Curves.elasticOut)));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .45)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.translate(
          offset: Offset(
            0,
            _offset.value == (widget.reverse ? 20 : -20)
                ? _bounce.value
                : _offset.value,
          ),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}

/// ElasticLeft/ElasticRight
class ElasticX extends StatefulWidget {
  final bool reverse;
  final Widget child;
  final AnimationController controller;

  ElasticX(this.child, this.controller, {Key key, this.reverse = false})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _ElasticXState createState() => _ElasticXState();
}

class _ElasticXState extends State<ElasticX> {
  Animation<double> _bounce, _offset, _opacity;

  @override
  void initState() {
    super.initState();
    _offset = Tween<double>(
            begin: widget.reverse ? 50 : -50, end: widget.reverse ? -20 : 20)
        .animate(CurvedAnimation(
            parent: widget.controller,
            curve: Interval(.3, 1, curve: Curves.easeOut)));
    _bounce = Tween<double>(begin: widget.reverse ? -20 : 20, end: 0).animate(
        CurvedAnimation(
            parent: widget.controller,
            curve: Interval(.3, 1, curve: Curves.elasticOut)));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(0, .45)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        child: widget.child,
        animation: widget.controller,
        builder: (BuildContext context, Widget child) => Transform.translate(
          offset: Offset(
            _offset.value == (widget.reverse ? -20 : 20)
                ? _bounce.value
                : _offset.value,
            0,
          ),
          child: Opacity(opacity: _opacity.value, child: child),
        ),
      );
}
