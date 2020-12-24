import 'package:flutter/material.dart';
import 'basis.dart';

class ToastBindingObserver with WidgetsBindingObserver {
  static final ToastBindingObserver _instance = ToastBindingObserver._();
  factory ToastBindingObserver() => _instance;
  List<ToastPopCheck> _handlers;

  ToastBindingObserver._() {
    _handlers = [];
    WidgetsBinding.instance.addObserver(this);
  }

  VoidCallback add(ToastPopCheck check) {
    assert(_handlers != null);
    _handlers.add(check);
    return () => _handlers.remove(check);
  }

  @override
  Future<bool> didPopRoute() async {
    if (_handlers.isNotEmpty) {
      final List<ToastPopCheck> copy =
          _handlers.reversed.toList(growable: false);
      for (ToastPopCheck handler in copy) if (handler()) return true;
    }
    return super.didPopRoute();
  }
}
