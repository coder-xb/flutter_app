import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../widget/index.dart';

/// Toast管理器
class ToastManager extends StatefulWidget {
  final Widget child;

  ToastManager({Key key, this.child}) : super(key: key);

  @override
  ToastManagerState createState() => ToastManagerState();
}

class ToastManagerState extends State<ToastManager> {
  int _sort = 0;
  final Set<UniqueKey> _pending = Set<UniqueKey>();
  final Map<String, Map<UniqueKey, ToastProxy>> _toasts = {};

  @override
  Widget build(BuildContext context) =>
      Stack(children: [widget.child]..addAll(_children));

  List<ToastProxy> get _children =>
      _toasts.values.fold([], (v, e) => v..addAll(e.values))
        ..sort((a, b) => a.sort.compareTo(b.sort));

  /// 保证在下一帧运行
  void _safeHandler(VoidCallback handler) {
    SchedulerBinding.instance.addPostFrameCallback((_) => handler());
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// 添加Toast
  void add(String group, UniqueKey key, Widget child) {
    _safeHandler(() {
      _toasts[group] ??= {};
      final UniqueKey uk = UniqueKey();
      child = ToastProxy(
        key: uk,
        child: child,
        sort: ++_sort,
        init: () => _pending.remove(key),
        dispose: () => _toasts[group]?.remove(key),
      );
      _toasts[group][key] = child;
      _pending.add(key);
      _update();
    });
  }

  /// 关闭指定[key]Toast
  void close(String group, UniqueKey key) {
    _safeHandler(() {
      // 首桢渲染完成之前,就被删除,需要确保[ToastProxy]构建完成,因此要放到下一帧进行删除
      if (_pending.contains(key)) return close(group, key);
      _toasts[group]?.remove(key);
      _update();
    });
  }

  /// 关闭全部Toast
  void closeAll(String group) {
    _safeHandler(() {
      if (_toasts[group] == null) return;
      _toasts[group].removeWhere((key, _) => !_pending.contains(key));
      _update();
      if (_toasts[group].isNotEmpty) {
        _toasts[group].forEach((key, value) => close(group, key));
      }
    });
  }

  /// 清除Toast
  void clean() {
    _safeHandler(() {
      _toasts.forEach((group, value) {
        assert(value != null);
        value.removeWhere((key, _) => !_pending.contains(key));
        if (value.isNotEmpty) value.forEach((key, value) => close(group, key));
      });
      _update();
    });
  }

  /// 界面更新
  void _update() {
    if (mounted) setState(() {});
  }
}
