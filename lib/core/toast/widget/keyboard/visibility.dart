import 'package:flutter/material.dart';

/// 键盘是否可见监控
class KeyboardVisibility extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onChange;

  KeyboardVisibility({Key key, @required this.child, @required this.onChange})
      : assert(child != null),
        assert(onChange != null),
        super(key: key);

  @override
  _KeyboardVisibilityState createState() => _KeyboardVisibilityState();
}

class _KeyboardVisibilityState extends State<KeyboardVisibility>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    widget.onChange(!(MediaQuery.of(context).viewInsets.bottom == 0));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
