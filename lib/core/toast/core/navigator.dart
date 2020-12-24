import 'package:flutter/material.dart';

/// 如项目有多个[Navigator],请将该[AppToastNavigator]添加到[Navigator.observers]
class AppToastNavigator extends NavigatorObserver {
  static final List<ToastNavigatorProxy> _proxys = [];

  static bool debugInitialization = false;

  AppToastNavigator() {
    assert(() {
      debugInitialization = true;
      return true;
    }());
  }

  static void add(ToastNavigatorProxy proxy) {
    assert(debugInitialization);
    assert(proxy != null);
    _proxys.add(proxy);
  }

  static void remove(ToastNavigatorProxy proxy) {
    assert(proxy != null);
    _proxys.remove(proxy);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    final copy = _proxys.toList(growable: false);
    for (ToastNavigatorProxy proxy in copy)
      proxy.didPush?.call(route, previousRoute);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    final copy = _proxys.toList(growable: false);
    for (ToastNavigatorProxy proxy in copy)
      proxy.didReplace?.call(newRoute, oldRoute);
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    final copy = _proxys.toList(growable: false);
    for (ToastNavigatorProxy proxy in copy)
      proxy.didRemove?.call(route, previousRoute);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    final copy = _proxys.toList(growable: false);
    for (ToastNavigatorProxy proxy in copy)
      proxy.didPop?.call(route, previousRoute);
  }
}

class ToastNavigatorProxy {
  void Function(Route route, Route previousRoute) didPush;
  void Function(Route newRoute, Route oldRoute) didReplace;
  void Function(Route route, Route previousRoute) didRemove;
  void Function(Route route, Route previousRoute) didPop;

  ToastNavigatorProxy(
      {this.didPush, this.didReplace, this.didRemove, this.didPop});

  ToastNavigatorProxy.all(VoidCallback pageCallback) {
    didPush = (_, __) => pageCallback();
    didReplace = (_, __) => pageCallback();
    didRemove = (_, __) => pageCallback();
    didPop = (_, __) => pageCallback();
  }
}
