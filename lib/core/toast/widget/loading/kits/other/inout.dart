import 'package:flutter/material.dart';

class KitInout extends StatefulWidget {
  final Color color;
  final double size;

  KitInout({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitInoutState createState() => _KitInoutState();
}

class _KitInoutState extends State<KitInout>
    with SingleTickerProviderStateMixin {
  double _last = 0;
  List<Widget> _children;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _children = List.generate(
      4,
      (i) => SizedBox.fromSize(
        size: Size.square(widget.size * .3),
        child: DecoratedBox(
          decoration:
              BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..repeat();
    _controller.addListener(() {
      if (_last > _controller.value)
        setState(() => _children.insert(0, _children.removeLast()));
      _last = _controller.value;
    });
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
        size: Size(widget.size * 1.2, widget.size),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _children
              .asMap()
              .map((index, value) {
                Widget inner = value;
                if (index == 0) inner = _builder(inner);
                if (index == 3) inner = _builder(inner, true);
                return MapEntry<int, Widget>(index, inner);
              })
              .values
              .toList(),
        ),
      ),
    );
  }

  AnimatedBuilder _builder(
    Widget innerWidget, [
    bool inverse = false,
  ]) =>
      AnimatedBuilder(
        animation: _controller,
        child: innerWidget,
        builder: (BuildContext context, Widget child) {
          final double val =
              inverse ? 1 - _controller.value : _controller.value;
          return SizedBox.fromSize(
            size: Size.square(widget.size * .3 * val),
            child: Opacity(child: child, opacity: val),
          );
        },
      );
}
