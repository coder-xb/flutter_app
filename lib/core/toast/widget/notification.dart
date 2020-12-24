import 'package:flutter/material.dart';
import '../core/basis.dart';

/// [通知提示]Toast
class NotificationToast extends StatefulWidget {
  final Color color; // 背景色
  final Border border; // 边框
  final VoidCallback onTap; // 点击整个toast的回调
  final ToastDismiss dismiss; // toast关闭回调
  final double radius, margin; // 圆角半径,外边距
  final String title, subTitle; // (副)标题
  final List<BoxShadow> shadow; // 阴影
  final Widget prefix, suffix; // 前(后)缀组件
  final TextStyle style, subStyle; // (副)标题样式
  final EdgeInsetsGeometry padding; // 内边距
  final bool suffixDismiss,
      slideDismiss,
      tapDismiss; // 点击[suffix]是否可以关闭,是否可滑动关闭,点击[toast]是否关闭
  final List<DismissDirection> directions; // 可滑动关闭的方向

  NotificationToast({
    Key key,
    @required this.title,
    @required this.dismiss,
    this.onTap,
    this.style,
    this.border,
    this.subTitle,
    this.prefix,
    this.suffix,
    this.subStyle,
    this.radius = 10,
    this.margin = 10,
    this.tapDismiss = true,
    this.slideDismiss = true,
    this.suffixDismiss = true,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.shadow = const [BoxShadow(color: Colors.black12, blurRadius: 10)],
    this.directions = const [DismissDirection.horizontal, DismissDirection.up],
  })  : assert(title != null),
        assert(padding != null),
        assert(dismiss != null),
        super(key: key);

  @override
  _NotificationToastState createState() => _NotificationToastState();
}

class _NotificationToastState extends State<NotificationToast> {
  UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    Widget child = widget.onTap != null
        ? GestureDetector(
            onTap: () {
              widget.onTap?.call();
              if (widget.tapDismiss) widget.dismiss?.call();
            },
            child: _toastView(),
          )
        : _toastView();
    if (widget.slideDismiss != null && widget.slideDismiss) {
      List<DismissDirection> directions = widget.directions ??
          [DismissDirection.horizontal, DismissDirection.up];
      directions.forEach((DismissDirection direction) {
        child = Dismissible(
          key: _key,
          child: child,
          direction: direction,
          confirmDismiss: (DismissDirection direction) async {
            widget.dismiss?.call();
            return true;
          },
        );
      });
    }
    return child;
  }

  Widget _toastView() => Container(
        margin: EdgeInsets.symmetric(horizontal: widget.margin),
        padding: widget.suffixDismiss
            ? EdgeInsets.fromLTRB(widget.padding.horizontal / 2,
                widget.padding.vertical / 2, 0, widget.padding.vertical / 2)
            : widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border,
          boxShadow: widget.shadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.prefix != null
                ? Container(
                    margin: EdgeInsets.only(right: 10), child: widget.prefix)
                : SizedBox.shrink(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: TextStyle(fontSize: 16, color: Color(0xFF333333))
                          .merge(widget.style)),
                  widget.subTitle != null
                      ? Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            widget.subTitle,
                            style: TextStyle(
                                    fontSize: 14, color: Color(0xFF333333))
                                .merge(widget.subStyle ?? widget.style),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            widget.suffix != null
                ? widget.suffixDismiss
                    ? GestureDetector(
                        onTap: () => widget.dismiss?.call(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          padding: EdgeInsets.only(
                              right: widget.padding.horizontal / 2),
                          child: widget.suffix,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(left: 10), child: widget.suffix)
                : SizedBox.shrink(),
          ],
        ),
      );
}
