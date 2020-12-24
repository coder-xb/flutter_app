class API {
  API._();

  static SocketModel scoket =
      SocketModel(pro: 'ws://', ip: '47.75.65.156', port: '8312');
}

class SocketModel {
  String ip, pro, port;
  SocketModel({this.ip, this.pro, this.port});
}
