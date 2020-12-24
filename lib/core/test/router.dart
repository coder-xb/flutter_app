import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterapp/main.dart';

class AppRouter extends NavigatorObserver {
  static AppRouter _router = AppRouter._();
  static final Map<String, Function> _configs = {
    '/': (BuildContext context, [Object args]) => HomePage(),
    '/second': (BuildContext context, [Object args]) => SecondPage(),
    //'/third': (BuildContext context, [Object args]) => ThirdPage(),
  };

  static final Function generate = (RouteSettings settings) {
    final Function builder = _configs[settings.name];
    return CupertinoPageRoute(
      settings: settings,
      builder: (BuildContext context) => settings.arguments == null
          ? builder(context)
          : builder(context, settings.arguments),
    );
  };

  AppRouter._() {
    _stream = StreamController.broadcast();
  }

  factory AppRouter() => _router;

  // 当前路由栈
  static List<Route> _routes = [];
  List<Route> get routes => _routes;
  Route get currentRoute => _routes[_routes.length - 1];
  String get currentName => currentRoute.settings.name;
  // stream相关
  static StreamController _stream;
  StreamController get stream => _stream;

  Future<Object> go(String name, [Object args]) =>
      navigator.pushNamed(name, arguments: args);

  void pop<T extends Object>([T res]) => navigator.pop(res);

  Future<Object> root(String name, [String keep]) =>
      navigator.pushNamedAndRemoveUntil(
          name, keep != null ? ModalRoute.withName(keep) : (r) => r == null);

  Future<Object> replace(String name, [Object args]) =>
      navigator.pushReplacementNamed(name, arguments: args);

  void popUntil(String name) =>
      navigator.popUntil((route) => route.settings.name == name);

  // 当调用Navigator.push时回调
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    // 这里过滤调push的是dialog的情况
    if (route is CupertinoPageRoute || route is MaterialPageRoute) {
      _routes.add(route);
      routeObserver();
    }
  }

  // 当调用Navigator.replace时回调
  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is CupertinoPageRoute || newRoute is MaterialPageRoute) {
      _routes.remove(oldRoute);
      _routes.add(newRoute);
      routeObserver();
    }
  }

  // 当调用Navigator.pop时回调
  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    if (route is CupertinoPageRoute || route is MaterialPageRoute) {
      _routes.remove(route);
      routeObserver();
    }
  }

  @override
  void didRemove(Route removedRoute, Route oldRoute) {
    super.didRemove(removedRoute, oldRoute);
    if (removedRoute is CupertinoPageRoute ||
        removedRoute is MaterialPageRoute) {
      _routes.remove(removedRoute);
      routeObserver();
    }
  }

  void routeObserver() {
    print('路由栈: $routes');
    print('当前路由: $currentRoute');
    print('当前路由名称: $currentName');
    _stream.sink.add(routes);
  }

  void clear() {
    _stream?.close();
    routes?.clear();
  }
}
