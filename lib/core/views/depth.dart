import 'package:flutter/material.dart';
import '../models/index.dart';
import '../renders/index.dart';

class Depth extends StatefulWidget {
  final List<DepthModel> bids, asks;
  Depth(this.bids, this.asks);
  @override
  _DepthState createState() => _DepthState();
}

class _DepthState extends State<Depth> {
  Offset _pressOffset;
  bool _isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        _pressOffset = details.globalPosition;
        _isLongPress = true;
        _notifyChanged();
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        _pressOffset = details.globalPosition;
        _isLongPress = true;
        _notifyChanged();
      },
      onTap: () {
        if (_isLongPress) {
          _isLongPress = false;
          _notifyChanged();
        }
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: DepthPainter(
          widget.bids,
          widget.asks,
          pressOffset: _pressOffset,
          isLongPress: _isLongPress,
        ),
      ),
    );
  }

  void _notifyChanged() => setState(() {});
}
