import 'package:flutter/material.dart';
import 'dart:async';

/// 数据派发及更新
class AppData {
  static final Map<String, _DataBus> _buses = {};

  static _DataBus<T> on<T>(String key, [T init]) {
    if (!_buses.containsKey(key)) _buses[key] = _DataBus<T>(init);
    return _buses[key];
  }

  static void remove(String key) {
    if (_buses[key] == null) return;
    _buses[key]?.close();
    _buses.remove(key);
  }

  static void clear() {
    _buses.values.forEach((e) => e?.close());
    _buses.clear();
  }
}

class _DataBus<T> {
  StreamController<T> _stream;

  T current;

  _DataBus([T init]) {
    current = init;
    _stream = StreamController<T>.broadcast();
  }

  Stream get stream => _stream.stream;
  StreamSink get sink => _stream.sink;

  void update(T data) {
    if (data == current) return;
    if (_stream.isClosed) return;
    current = data;
    sink.add(data);
  }

  void close() {
    _stream?.close();
  }

  Widget observer(ViewBuilder<T> builder) => _DataObserver<T>(this, builder);
}

typedef ViewBuilder<T> = Function(BuildContext context, T val);

class _DataObserver<T> extends StatefulWidget {
  final _DataBus<T> bus;
  final ViewBuilder<T> builder;

  _DataObserver(this.bus, this.builder, {Key key}) : super(key: key);

  @override
  _DataObserverState<T> createState() => _DataObserverState<T>();
}

class _DataObserverState<T> extends State<_DataObserver<T>> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.bus.stream,
      initialData: widget.bus.current, // 由于没有用rxdart，只有使用这种方式来引入初始值
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return snapshot.hasData
            ? widget.builder(context, snapshot.data)
            : SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.bus?.close();
  }
}
