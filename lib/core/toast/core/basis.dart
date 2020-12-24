import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef void ToastDismiss(); // Toast关闭回调
typedef bool ToastPopCheck(); // Toast弹出判定
typedef Future<void> ToastFuturer(); // ToastFuture处理
typedef Widget ToastBuilder(ToastDismiss dismiss); // Toast构建器
typedef Widget ToastWrapper(Widget child, ToastDismiss dismiss); // Toast包裹组件
typedef Widget ToastAnimator(Widget child, AnimationController controller,
    ToastDismiss dismiss); // Toast动画组件

/// 物理返回按键点击
enum ToastBackBehavior {
  none, // 不作任何处理
  ignore, // 拦截此次点击
  close, // 拦截并关闭Toast
}

/// Toast吸附方向(顺序不可改变)
/// 主方向+对齐方向
enum ToastAttached {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  leftTop,
  leftCenter,
  leftBottom,
  rightTop,
  rightCenter,
  rightBottom
}

class ToastTicker extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
