import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';
import 'api.dart';

typedef DataCallback = void Function(Map<String, dynamic> data);

class $WebSocket {
  $WebSocket._();
  static Timer _timer;
  static $WebSocket _ins;
  static String _prev, _cur;
  static final int _time = 5; // 每5s发送一次心跳
  static DataCallback _callback;
  static IOWebSocketChannel _channel;
  factory $WebSocket(String val, {DataCallback callback}) =>
      $WebSocket._socket(val, callback: callback);
  static $WebSocket _socket(
    String val, {
    DataCallback callback,
  }) {
    _cur = val;
    _callback = callback;
    if (_ins == null) _ins = $WebSocket._();
    _create();
    return _ins;
  }

  /// 创建连接
  static void _create() async {
    if (_channel == null) {
      _channel = IOWebSocketChannel.connect(
          '${API.scoket.pro + API.scoket.ip}:${API.scoket.port}');
      print('WEBSOCKET - CONNECT!');
      _timer?.cancel();
      _channel.stream.listen(_data, onDone: _done, onError: _error);
      _heart(); // 发送心跳包
    }

    _sub(); // 发送订阅数据
  }

  /// 数据返回
  static void _data(msg) {
    if (_callback != null) _callback(json.decode(msg));
  }

  /// 订阅
  static void _sub() {
    if (_cur == _prev) return; // 与上一次的数据相比较
    if (_prev != null && _prev.isNotEmpty)
      _unsub(); // 先取消上一次订阅
    else
      _prev = _cur;

    print('SUB: $_cur');
    _channel.sink.add(json.encode({'sub': _cur}).toString()); // 再发送新的订阅数据
  }

  /// 取消订阅
  static void _unsub() {
    print('UNSUB: $_prev');
    _channel.sink.add(json.encode({'unsub': _prev}).toString()); // 发送取消数据
    _prev = _cur; // 缓存新的数据
  }

  /// 发送心跳包数据
  static void _heart() {
    _timer = Timer.periodic(Duration(seconds: _time), (_) {
      _channel.sink.add(json.encode({'type': 'ping'}).toString());
    });
  }

  /// 连接断开
  static void _done() {
    print('WEBSOCKET - DONE!');
    if (_channel?.closeCode != normalClosure) _create();
    _prev = null;
    _channel = null;
  }

  /// 连接错误
  static void _error(error) {
    print('WEBSOCKET - ERROR: $error');
    _channel = null;
    _create(); // 重新创建连接
  }

  /// 关闭Websocket连接
  void close() async {
    if (_channel != null) {
      if (_prev != null && _prev.isNotEmpty) _unsub(); // 先取消上一次订阅
      _timer?.cancel();
      await _channel.sink.close();
      print('WEBSOCKET - CLOSE！');
    }
  }
}
