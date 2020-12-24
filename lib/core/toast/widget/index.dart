import 'package:flutter/material.dart';
export 'text.dart';
export 'attached.dart';
export 'position.dart';
export 'notification.dart';
export 'loading/index.dart';
export 'keyboard/index.dart';
export 'animation/index.dart';

class ToastProxy extends StatefulWidget {
  final int sort;
  final Widget child;
  final VoidCallback init, dispose;

  const ToastProxy(
      {Key key, this.init, this.dispose, this.sort = 0, @required this.child})
      : assert(child != null),
        assert(init != null || dispose != null),
        super(key: key);

  @override
  _ToastProxyState createState() => _ToastProxyState();
}

class _ToastProxyState extends State<ToastProxy> {
  @override
  void initState() {
    super.initState();
    widget.init?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.dispose?.call();
    super.dispose();
  }
}
