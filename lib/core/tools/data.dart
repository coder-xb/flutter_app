import 'dart:math';
import 'num.dart';
import '../models/index.dart';

class Data {
  static void calculate(List<KLineModel> data) {
    if (data == null) return;
    _calcPriceMA(data);
    _calcBOLL(data);
    _calcVolMA(data);
    _calcKDJ(data);
    _calcMACD(data);
    _calcRSI(data);
    _calcWR(data);
  }

  /// 增量更新时计算最后一个数据
  static addLast(List<KLineModel> data, KLineModel model) {
    if (data == null || model == null) return;
    data.add(model);
    _calcPriceMA(data, true);
    _calcBOLL(data, true);
    _calcVolMA(data, true);
    _calcKDJ(data, true);
    _calcMACD(data, true);
    _calcRSI(data, true);
    _calcWR(data, true);
  }

  /// 更新最后一条数据
  static updateLast(List<KLineModel> data, KLineModel model) {
    if (data == null || model == null) return;
    data.last = model;
    _calcPriceMA(data, true);
    _calcBOLL(data, true);
    _calcVolMA(data, true);
    _calcKDJ(data, true);
    _calcMACD(data, true);
    _calcRSI(data, true);
    _calcWR(data, true);
  }

  /// MA指标 ---- 移动平均线指标
  /// 计算公式: N日MA=N日收市价的总和/N(即算术平均数)
  /// 要设置多条移动平均线，一般参数设置为N1=5,N2=10,N3=20,N4=60,N5=120,N6=250
  static void _calcPriceMA(List<KLineModel> data, [bool last = false]) {
    int i = 0;
    double ma5 = 0, ma10 = 0, ma20 = 0, ma30 = 0;
    if (last && data.length > 1) {
      i = data.length - 1;
      KLineModel model = data[i - 1];
      ma5 = Num.mul(model.priceMA5, 5);
      ma10 = Num.mul(model.priceMA10, 10);
      ma20 = Num.mul(model.priceMA20, 20);
      ma30 = Num.mul(model.priceMA30, 30);
      // ma5 = model.priceMA5 * 5;
    }
    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      ma5 = Num.add(ma5, model.close);
      ma10 = Num.add(ma10, model.close);
      ma20 = Num.add(ma20, model.close);
      ma30 = Num.add(ma30, model.close);
      // ma5 += model.close;

      if (i == 4) {
        model.priceMA5 = Num.div(ma5, 5);
        // model.priceMA5 = ma5 / 5;
      } else if (i >= 5) {
        ma5 = Num.sub(ma5, data[i - 5].close);
        // ma5 -= data[i - 5].close;
        model.priceMA5 = Num.div(ma5, 5);
      } else
        model.priceMA5 = 0;

      if (i == 9) {
        model.priceMA10 = Num.div(ma10, 10);
      } else if (i >= 10) {
        ma10 = Num.sub(ma10, data[i - 10].close);
        model.priceMA10 = Num.div(ma10, 10);
      } else
        model.priceMA10 = 0;

      if (i == 19) {
        model.priceMA20 = Num.div(ma20, 20);
      } else if (i >= 20) {
        ma20 = Num.sub(ma20, data[i - 20].close);
        model.priceMA20 = Num.div(ma20, 20);
      } else
        model.priceMA20 = 0;

      if (i == 29) {
        model.priceMA30 = Num.div(ma30, 30);
      } else if (i >= 30) {
        ma30 = Num.sub(ma30, data[i - 30].close);
        model.priceMA30 = Num.div(ma30, 30);
      } else
        model.priceMA30 = 0;

      /*if (i == 59) {
        model.priceMA60 = Num.div(ma60, 60);
      } else if (i >= 60) {
        ma60 = Num.sub(ma60, data[i - 60].close);
        model.priceMA60 = Num.div(ma60, 60);
      } else
        model.priceMA60 = 0;*/
    }
  }

  static void _calcVolMA(List<KLineModel> data, [bool last = false]) {
    double ma5 = 0, ma10 = 0;

    int i = 0;
    if (last && data.length > 1) {
      i = data.length - 1;
      KLineModel model = data[i - 1];
      ma5 = Num.mul(model.volMA5, 5);
      ma10 = Num.mul(model.volMA10, 10);
      // ma5 = model.volMA5 * 5;
    }

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      ma5 = Num.add(ma5, model.vol);
      ma10 = Num.add(ma10, model.vol);
      // ma5 += model.vol;

      if (i == 4) {
        model.volMA5 = Num.div(ma5, 5);
        // model.volMA5 = ma5 / 5;
      } else if (i >= 5) {
        ma5 = Num.sub(ma5, data[i - 5].vol);
        // ma5 -= data[i - 5].vol;
        model.volMA5 = Num.div(ma5, 5);
      } else
        model.volMA5 = 0;
      if (i == 9) {
        model.volMA10 = Num.div(ma10, 10);
      } else if (i >= 10) {
        ma10 = Num.sub(ma10, data[i - 10].vol);
        model.volMA10 = Num.div(ma10, 10);
      } else
        model.volMA10 = 0;
    }
  }

  /// BOLL指标 ---- 布林线指标
  /// 以日BOLL指标计算为例(k为参数，可根据股票的特性来做相应的调整，一般默认为2):
  /// 计算公式:
  ///   MB(中轨线) = N日的移动平均线(MA)
  ///   UP(上轨线) = MB(中轨线) + k倍的标准差(k * MD)
  ///   DN(下轨线) = MB(中轨线) - k倍的标准差(k * MD)
  /// 计算过程:
  ///   1.计算MA: MA = N日内的收盘价之和/N
  ///   2.计算标准差MD(C指收盘价):
  ///     MD = 平方根（N-1）日的（C－MA）的两次方之和除以N
  ///   3.计算MB、UP和DN线
  ///     MB = (N－1)日的MA
  ///     UP = MB + k * MD
  ///     DN = MB - k * MD
  static void _calcBOLL(List<KLineModel> data, [bool last = false]) {
    int i = 0;
    if (last && data.length > 1) i = data.length - 1;

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      if (i < 19) {
        model.mb = model.up = model.dn = 0;
      } else {
        int n = 20;
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = data[j].close, m = model.priceMA20, val = Num.sub(c, m);
          md = Num.add(md, Num.mul(val, val));
          // md = md + val * val;
        }
        md = Num.div(md, n - 1);
        // md = md / (n - 1);
        md = Num.sqrt(md);

        model.mb = model.priceMA20;
        model.up = Num.add(model.mb, Num.mul(2.0, md));
        // model.up = model.mb + 2.0 * md;
        model.dn = Num.sub(model.mb, Num.mul(2.0, md));
        // model.dn = model.mb - 2.0 * md;
      }
    }
  }

  /// MACD指标 ---- 异同移动平均线“指数平滑移动平均线”
  /// 先行计算出快速(一般选12日)移动平均值与慢速(一般选26日)移动平均值。
  /// 以这两个数值作为测量两者(快速与慢速线)间的“差离值”依据。所谓“差离值”(DIF)
  /// 即12日EMA数值减去26日EMA数值。
  /// 离差平均值(DEA), 根据离差值计算其9日的EMA, 即离差平均值, 是所求的MACD值
  static void _calcMACD(List<KLineModel> data, [bool last = false]) {
    double dif = 0, dea = 0, macd = 0, ema12 = 0, ema26 = 0;

    int i = 0;
    if (last && data.length > 1) {
      i = data.length - 1;
      KLineModel model = data[i - 1];
      dif = model.dif;
      dea = model.dea;
      macd = model.macd;
      ema12 = model.ema12;
      ema26 = model.ema26;
    }

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      final double close = model.close;
      if (i == 0) {
        ema12 = ema26 = close;
      } else {
        // EMA12 = 前一日EMA12 * 11/13 + 今日收盘价 * 2/13
        // ema12 = ema12 * 11 / 13 + close * 2 / 13;
        ema12 = Num.add(
            Num.div(Num.mul(ema12, 11), 13), Num.div(Num.mul(close, 2), 13));
        // EMA26 = 前一日EMA26 * 25/27 + 今日收盘价 * 2/27
        // ema26 = ema26 * 25 / 27 + close * 2 / 27;
        ema26 = Num.add(
            Num.div(Num.mul(ema26, 25), 27), Num.div(Num.mul(close, 2), 27));
      }
      // DIF = 今日EMA12 - 今日EMA26
      // 今日DEA = 前一日DEA * 8/10 + 今日DIF * 2/10
      // 用(DIF-DEA) * 2即为MACD柱状图
      dif = Num.sub(ema12, ema26);
      // dif = ema12 - ema26
      dea = Num.add(Num.div(Num.mul(dea, 8), 10), Num.div(Num.mul(dif, 2), 10));
      // dea = dea * 8 / 10 + dif * 2 / 10
      macd = Num.mul(Num.sub(dif, dea), 2);
      // macd = (dif - dea) / 2
      model.dif = dif;
      model.dea = dea;
      model.macd = macd;
      model.ema12 = ema12;
      model.ema26 = ema26;
    }
  }

  /// RSI相对强弱指标
  /// 计算公式：N日RSI = N日内收盘涨幅的平均值 / (N日内收盘涨幅均值+N日内收盘跌幅均值) * 100
  static void _calcRSI(List<KLineModel> data, [bool last = false]) {
    double rsi = 0, rsiABSEma = 0, rsiMaxEma = 0;

    int i = 0;
    if (last && data.length > 1) {
      i = data.length - 1;
      KLineModel model = data[i - 1];
      rsi = model.rsi;
      rsiABSEma = model.rsiABSEma;
      rsiMaxEma = model.rsiMaxEma;
    }

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      final double close = model.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double rMax = max(0, close - data[i - 1].close),
            rABS = (close - data[i - 1].close).abs();
        rsiMaxEma = Num.div(Num.add(rMax, Num.mul(13, rsiMaxEma)), 14);
        rsiABSEma = Num.div(Num.add(rABS, Num.mul(13, rsiABSEma)), 14);
        // rsiMaxEma = (rMax + (14 - 1) * rsiMaxEma) / 14;
        rsi = Num.mul(Num.div(rsiMaxEma, rsiABSEma), 100);
        // rsi = (rsiMaxEma / rsiABSEma) * 100
      }
      if (i < 13) rsi = 0;
      if (rsi.isNaN) rsi = 0;
      model.rsi = rsi;
      model.rsiABSEma = rsiABSEma;
      model.rsiMaxEma = rsiMaxEma;
    }
  }

  /// KDJ随机指标
  /// 以最高价、最低价及收盘价为基本数据进行计算，
  /// 得出的K值、D值和J值分别在指标的坐标上形成的一个点，
  /// 连接无数个这样的点位，就形成一个完整的、能反映价格波动趋势的KDJ指标。
  static void _calcKDJ(List<KLineModel> data, [bool last = false]) {
    double k = 0, d = 0;

    int i = 0;
    if (last && data.length > 1) {
      i = data.length - 1;
      KLineModel model = data[i - 1];
      k = model.k;
      d = model.d;
    }

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      final double close = model.close;
      int startIndex = i - 13;
      if (startIndex < 0) startIndex = 0;

      double h14 = -double.maxFinite, l14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        l14 = min(l14, data[index].low);
        h14 = max(h14, data[index].high);
      }

      /// 未成熟随机值RSV
      double rsv =
          Num.mul(100, Num.div(Num.sub(close, l14), Num.sub(h14, l14)));

      if (i == 0) {
        k = d = 50;
      } else {
        k = Num.div(
            Num.add(rsv, Num.mul(2, k)), 3); // 当日K值 = 2/3 * 前一日K值+1/3 * 当日RSV
        // k = (rsv + 2 * k) / 3
        d = Num.div(
            Num.add(k, Num.mul(2, d)), 3); // 当日D值 = 2/3 * 前一日D值+1/3 * 当日K值
        // d = (k + 2 * d) / 3
      }
      if (i < 13) {
        model.k = 0;
        model.d = 0;
        model.j = 0;
      } else if (i == 13 || i == 14) {
        model.k = k;
        model.d = 0;
        model.j = 0;
      } else {
        model.k = k;
        model.d = d;
        model.j =
            Num.sub(Num.mul(3, k), Num.mul(2, d)); // J值 = 3 * 第n日K值 - 2 * 第n日D值
        // model.j = 3 * k - 2 * d;
      }
    }
  }

  /// %R值 ---- 威廉指标(振荡指标)
  /// 计算公式：
  /// %R  =  (Hn—C) / (Hn—Ln) * 100
  /// n：是交易者设定的交易期间(常用为30天)
  /// C：第n日的最新收盘价
  /// Hn：是过去n日内的最高价(如30天的最高价)
  /// Ln：是过去n日内的最低价(如30天的最低价)
  static void _calcWR(List<KLineModel> data, [bool last = false]) {
    int i = 0;
    if (last && data.length > 1) i = data.length - 1;

    for (int len = data.length; i < len; i++) {
      KLineModel model = data[i];
      int startIndex = i - 14;
      if (startIndex < 0) startIndex = 0;

      double h14 = -double.maxFinite, l14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        l14 = min(l14, data[index].low);
        h14 = max(h14, data[index].high);
      }
      if (i < 13 || Num.eq(Num.sub(h14, l14), 0)) {
        model.r = 0;
      } else
        model.r =
            Num.mul(100, Num.div(Num.sub(h14, model.close), Num.sub(h14, l14)));
      // model.r = 100 * (h14 - model.close) / (h14 - l14);
    }
  }
}
