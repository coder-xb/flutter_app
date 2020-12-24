import 'mixins.dart';

class KLineModel extends KModel {
  int id, count;
  double low, vol, open, high, close, amount;

  KLineModel({
    this.id, // K线ID
    this.low, // 最低价
    this.vol, // 成交额, 即 sum(每一笔成交价 * 该笔的成交量)
    this.high, // 最高价
    this.open, // 开盘价
    this.count, // 成交笔数
    this.close, // 收盘价,当K线为最晚的一根时，是最新成交价
    this.amount, // 成交量
  });

  factory KLineModel.fromJson(Map<String, dynamic> json) => KLineModel(
        id: (json['id'] as num)?.toInt(),
        low: (json['low'] as num)?.toDouble(),
        vol: (json['vol'] as num)?.toDouble(),
        count: (json['count'] as num)?.toInt(),
        high: (json['high'] as num)?.toDouble(),
        open: (json['open'] as num)?.toDouble(),
        close: (json['close'] as num)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'open': this.open,
        'close': this.close,
        'high': this.high,
        'low': this.low,
        'vol': this.vol,
        'amount': this.amount,
        'count': this.count,
      };

  @override
  String toString() {
    return 'KLineModel {open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}

class WinInfoModel {
  KLineModel model;
  bool left = false;

  WinInfoModel(
    this.model, {
    this.left = false,
  });
}
