class KModel
    with CandleMixin, VolMinxin, KDJMixin, RSIMixin, WRMixin, MACDMixin {}

mixin CandleMixin {
  double up, // 上轨线
      mb, // 中轨线
      dn, // 下轨线
      open, // 开盘价
      high, // 最高价
      low, // 最低价
      close, // 收盘价
      priceMA5,
      priceMA10,
      priceMA20,
      priceMA30;
  // priceMA60;
}

/// KDJ随机指标
mixin KDJMixin {
  /// 以最高价、最低价及收盘价为基本数据进行计算，
  /// 得出的K值、D值和J值分别在指标的坐标上形成的一个点，
  /// 连接无数个这样的点位，就形成一个完整的、能反映价格波动趋势的KDJ指标。
  double k, d, j;

  /// KDJ计算方法:
  /// KDJ的计算比较复杂，首先要计算周期 (n日、n周等) 的RSV值，
  /// 即未成熟随机指标值，然后再计算K值、D值、J值等。
  /// 以n日KDJ数值的计算为例，其计算公式为:
  /// n日RSV =  (Cn - Ln) / (Hn - Ln) * 100
  /// 公式中，Cn为第n日收盘价；Ln为n日内的最低价；Hn为n日内的最高价。
  /// 其次，计算K值与D值：
  /// 当日K值 = 2/3 * 前一日K值+1/3 * 当日RSV
  /// 当日D值 = 2/3 * 前一日D值+1/3 * 当日K值
  /// 若无前一日K 值与D值，则可分别用50来代替。
  /// J值 = 3*当日K值-2*当日D值
  /// 以9日为周期的KD线为例，即未成熟随机值，计算公式为
  /// 9日RSV = (C - L9) / (H9 - L9)  * 100%
  /// 公式中，C为第9日的收盘价；L9为9日内的最低价；H9为9日内的最高价。
  /// K值 = 2/3 * 第8日K值 + 1/3 * 第9日RSV
  /// D值 = 2/3 * 第8日D值 + 1/3 * 第9日K值
  /// J值 = 3 * 第9日K值 - 2 * 第9日D值
  /// 若无前一日K值与D值，则可以分别用50代替.
}

/// RSI相对强弱指标
mixin RSIMixin {
  double rsi, rsiABSEma, rsiMaxEma;

  /// 计算公式：
  /// N日RSI = N日内收盘涨幅的平均值 / (N日内收盘涨幅均值+N日内收盘跌幅均值) * 100
}

/// %R值 ---- 威廉指标(振荡指标)
mixin WRMixin {
  double r;

  /// 计算公式：
  /// %R  =  (Hn—C) / (Hn—Ln) * 100
  /// n：是交易者设定的交易期间(常用为30天)
  /// C：第n日的最新收盘价
  /// Hn：是过去n日内的最高价(如30天的最高价)
  /// Ln：是过去n日内的最低价(如30天的最低价)
}

/// 成交量 MAx ---- x日均线
mixin VolMinxin {
  double vol, open, close, volMA5, volMA10;
}

/// MACD指标 ---- 异同移动平均线“指数平滑移动平均线”
mixin MACDMixin on KDJMixin, RSIMixin, WRMixin {
  /// 先行计算出快速(一般选12日)移动平均值与慢速(一般选26日)移动平均值。
  /// 以这两个数值作为测量两者(快速与慢速线)间的“差离值”依据。所谓“差离值”(DIF)
  /// 即12日EMA数值减去26日EMA数值。
  /// 离差平均值(DEA), 根据离差值计算其9日的EMA, 即离差平均值, 是所求的MACD值
  double dea, // 用(DIF-DEA) * 2即为MACD柱状图
      dif, // 差离值(DIF): 今日EMA12 - 今日EMA26
      macd, // 今日DEA(MACD)  = 前一日DEA * 8/10+今日DIF * 2/10
      ema12, // 12日移动平均值(EMA): 前一日EMA12 * 11/13 + 今日收盘价 * 2/13
      ema26; // 26日移动平均值(EMA): 前一日EMA26 * 25/27 + 今日收盘价 * 2/27

}
