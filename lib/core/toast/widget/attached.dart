import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/basis.dart';

/// 吸附式Layout，以[Offset(0,app导航栏高度)]为原点
class AttachedLayout extends SingleChildLayoutDelegate {
  final Rect target; // 目标Widget
  final bool safeArea;
  final ToastAttached attached; // 吸附位置
  final double vertical, horizontal; // 距离目标Widget的左右(上下)间距

  AttachedLayout({
    this.safeArea = true,
    @required this.target,
    @required this.vertical,
    @required this.horizontal,
    this.attached = ToastAttached.topCenter,
  })  : assert(target != null),
        assert(vertical != null),
        assert(horizontal != null);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double top =
        safeArea ? MediaQueryData.fromWindow(window).padding.top : 0;
    return _offsetHandler(
      target: target,
      size: childSize,
      vertical: vertical ?? 0,
      horizontal: horizontal ?? 0,
      attached: attached ?? ToastAttached.topCenter,
      container: Rect.fromLTWH(0, top, size.width, size.height - top),
    );
  }

  @override
  bool shouldRelayout(AttachedLayout oldDelegate) =>
      target != oldDelegate.target ||
      vertical != oldDelegate.vertical ||
      attached != oldDelegate.attached;

  /// 位置[Offset]推断处理
  Offset _offsetHandler({
    @required Size size,
    @required Rect target,
    @required Rect container,
    @required ToastAttached attached,
    double vertical = 0,
    double horizontal = 0,
  }) {
    assert(size != null);
    assert(target != null);
    assert(attached != null);
    assert(container != null);
    assert(vertical != null && vertical >= 0);
    assert(horizontal != null && horizontal >= 0);

    /// 裁剪
    target = container.overlaps(target)
        ? target.intersect(container)
        : Rect.fromLTWH(container.left, container.top, 0, 0);

    /// 获取[attached]字符串
    String attach = _attachedHandler(
        attached, size, target, container, vertical, horizontal);
    return _positionHandler(
        attach, size, target, container, vertical, horizontal);
  }

  /// [attached]方向处理
  String _attachedHandler(ToastAttached attached, Size size, Rect target,
      Rect container, double vertical, double horizontal) {
    /// 位置判断
    bool top([double extra = 0]) =>
        size.height + vertical < target.top - container.top + extra;
    bool bottom([double extra = 0]) =>
        size.height + vertical < container.bottom - target.bottom + extra;
    bool left([double extra = 0]) =>
        size.width + horizontal < target.left - container.left + extra;
    bool right([double extra = 0]) =>
        size.width + horizontal < container.right - target.right + extra;

    /// 方向字符串格式化
    String attach(ToastAttached attached) =>
        attached.toString().replaceFirst('ToastAttached.', '');

    String result = '';

    /// 主方向判断
    if (attached.index <= ToastAttached.topRight.index) {
      result = top() ? 'top' : 'bottom';
    } else if (attached.index <= ToastAttached.bottomRight.index) {
      result = bottom() ? 'bottom' : 'top';
    } else if (attached.index <= ToastAttached.leftBottom.index) {
      result = bottom() ? 'left' : 'right';
    } else
      result = bottom() ? 'right' : 'left';

    /// 对齐方向判断
    if (attached.index <= ToastAttached.bottomRight.index) {
      switch (attach(attached).replaceAll('top', '').replaceAll('bottom', '')) {
        case 'Left':
          result += right(target.width)
              ? 'Left'
              : left(target.width)
                  ? 'Right'
                  : 'Center';
          break;
        case 'Right':
          result += left(target.width)
              ? 'Right'
              : right(target.width)
                  ? 'Left'
                  : 'Center';
          break;
        default:
          result += 'Center';
          break;
      }
    } else {
      switch (attach(attached).replaceAll('left', '').replaceAll('right', '')) {
        case 'Top':
          result += bottom(target.height)
              ? 'Top'
              : top(target.height)
                  ? 'Bottom'
                  : 'Center';
          break;
        case 'Bottom':
          result += top(target.height)
              ? 'Bottom'
              : bottom(target.height)
                  ? 'Top'
                  : 'Center';
          break;
        default:
          result += 'Center';
          break;
      }
    }
    return result;
  }

  /// 位置[Position]判断进一步处理
  Offset _positionHandler(String attached, Size size, Rect target,
      Rect container, double vertical, double horizontal) {
    Offset result = Offset.zero;

    switch (attached) {
      case 'topLeft':
        result = target.topLeft - Offset(-horizontal, size.height + vertical);
        break;
      case 'topCenter':
        bool right = size.width / 2 > container.right - target.topCenter.dx,
            left = size.width / 2 > target.topCenter.dx - container.left;
        if (right && !left) {
          result =
              Offset(container.right - size.width, target.top - size.height);
        } else if (!right && left) {
          result = Offset(container.left, target.top - size.height);
        } else
          result = target.topCenter - Offset(size.width / 2, size.height);
        result += Offset(0, -vertical);
        break;
      case 'topRight':
        result = target.topRight -
            Offset(size.width + horizontal, size.height + vertical);
        break;
      case 'bottomLeft':
        result = target.bottomLeft + Offset(horizontal, vertical);
        break;
      case 'bottomCenter':
        bool right = size.width / 2 > container.right - target.topCenter.dx,
            left = size.width / 2 > target.topCenter.dx - container.left;
        if (right && !left) {
          result = Offset(container.right - size.width, target.bottom);
        } else if (!right && left) {
          result = Offset(container.left, target.bottom);
        } else
          result = target.bottomCenter - Offset(size.width / 2, 0);
        result += Offset(0, vertical);
        break;
      case 'bottomRight':
        result =
            target.bottomRight - Offset(size.width + horizontal, -vertical);
        break;
      case 'leftTop':
        result = target.topLeft - Offset(size.width + horizontal, -vertical);
        break;
      case 'leftCenter':
        bool top = size.height / 2 > target.centerLeft.dy - container.top,
            bottom = size.height / 2 > container.bottom - target.centerLeft.dy;
        if (top && !bottom) {
          result = Offset(target.left - size.width, container.top);
        } else if (!top && bottom) {
          result =
              Offset(target.left - size.width, container.bottom - size.height);
        } else
          result = target.centerLeft - Offset(size.width, size.height / 2);
        result += Offset(-horizontal, 0);
        break;
      case 'leftBottom':
        result = target.bottomLeft -
            Offset(size.width + horizontal, size.height + vertical);
        break;
      case 'rightTop':
        result = target.topRight + Offset(horizontal, vertical);
        break;
      case 'rightCenter':
        bool top = size.height / 2 > target.centerLeft.dy - container.top,
            bottom = size.height / 2 > container.bottom - target.centerLeft.dy;
        if (top && !bottom) {
          result = Offset(target.right, container.top);
        } else if (!top && bottom) {
          result = Offset(target.right, container.bottom - size.height);
        } else
          result = target.centerRight - Offset(0, size.height / 2);
        result += Offset(horizontal, 0);
        break;
      case 'rightBottom':
        result =
            target.bottomRight - Offset(-horizontal, size.height + vertical);
        break;
    }
    return result;
  }
}
