import 'package:flutter/material.dart';

/// 基于Offset距离底部为0时
class KeyboardSafeArea extends StatelessWidget {
  final bool enable;
  final Widget child;

  KeyboardSafeArea({Key key, @required this.child, this.enable = true})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enable) return child;
    MediaQueryData media = MediaQuery.of(context, nullOk: true);
    return Padding(
      padding:
          EdgeInsets.only(bottom: media != null ? media.viewInsets.bottom : 0),
      child: child,
    );
  }
}
