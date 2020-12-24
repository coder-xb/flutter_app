import 'package:flutter/material.dart';

class KitChaseDots extends StatefulWidget {
  final Color color;
  final double size;

  KitChaseDots({Key key, this.color = Colors.white, this.size = 50})
      : assert(color != null),
        assert(size != null && size >= 0),
        super(key: key);

  @override
  _KitChaseDotsState createState() => _KitChaseDotsState();
}

class _KitChaseDotsState extends State<KitChaseDots>
    with TickerProviderStateMixin {
  Animation<double> _scale, _rotate;
  AnimationController _scaleController, _rotateController;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..addListener(() => setState(() {}))
          ..repeat(reverse: true);
    _scale = Tween<double>(begin: -1, end: 1).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    _rotateController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..addListener(() => setState(() {}))
          ..repeat();
    _rotate = Tween<double>(begin: 0, end: 360).animate(
        CurvedAnimation(parent: _rotateController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Transform.rotate(
          angle: _rotate.value * .0174533,
          child: Stack(
            children: [
              Positioned(top: 0, child: _view(1 - _scale.value.abs())),
              Positioned(bottom: 0, child: _view(_scale.value.abs())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _view(double scale) => Transform.scale(
        scale: scale,
        child: SizedBox.fromSize(
          size: Size.square(widget.size * 0.6),
          child: DecoratedBox(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ),
      );
}
