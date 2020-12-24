import 'dart:math';
import 'package:flutter/material.dart';
import '../../tools/index.dart';
import '../../views/style.dart';
import '../../views/chart.dart';
import '../../models/index.dart';

abstract class BasePainter extends CustomPainter {
  static double maxScrollX = 0;
  List<KLineModel> data;
  VolType volType = VolType.VOL;
  MainType mainType = MainType.MA;
  MinorType minorType = MinorType.MACD;

  double scaleX = 0, scrollX = 0, selectX;
  bool isLongPress = false, isLine = false;

  /// 3块区域大小及其位置
  Rect volRect, mainRect, minorRect;
  double width, displayHeight;

  int startIndex = 0, stopIndex = 0;
  double volMaxVal = -double.maxFinite, volMinVal = double.maxFinite;
  double mainMaxVal = -double.maxFinite, mainMinVal = double.maxFinite;
  double minorMaxVal = -double.maxFinite, minorMinVal = double.maxFinite;
  double translateX = -double.maxFinite;
  int mainMaxIndex = 0, mainMinIndex = 0;
  double mainHighMaxVal = -double.maxFinite, mainLowMinVal = double.maxFinite;
  int modelCount = 0;
  double dataLenght = 0, // 数据占屏幕总长度
      pointGap = ChartStyle.pointGap, // 点与点的间隙
      rightMargin = 0; // K线右边空出来的距离
  String timeFmt = 'yy-mm-dd hh:nn'; // 时间格式

  BasePainter(
    this.data, {
    this.isLine,
    this.volType,
    this.mainType,
    this.minorType,
    @required this.scaleX,
    @required this.scrollX,
    @required this.selectX,
    @required this.isLongPress,
  }) {
    modelCount = data?.length ?? 0;
    dataLenght = modelCount * pointGap;
    if (modelCount > 1) {
      int first = data.first?.id ?? 0,
          second = data[0]?.id ?? 0,
          tm = second - first;

      if (tm >= 24 * 60 * 60 * 28) {
        timeFmt = 'yy-mm'; // 月线
      } else if (tm >= 24 * 60 * 60) {
        timeFmt = 'yy-mm-dd'; // 日线
      } else
        timeFmt = 'hh:nn'; // 时线
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    initRect(size); // 初始化区块
    calcVal(); // 计算各种指标
    initRender();

    canvas.save();
    canvas.scale(1, 1);
    drawBg(canvas, size);
    drawGrid(canvas);
    if (data != null && data.isNotEmpty && data.length != 0) {
      drawChart(canvas, size);
      drawRightData(canvas);
      drawRealTimePrice(canvas, size);
      drawDate(canvas, size);
      if (isLongPress) drawCrossLineData(canvas, size);
      drawData(canvas, data?.last, 5);
      drawMost(canvas);
    }
    canvas.restore();
  }

  /// 初始化渲染器
  void initRender();

  /// 绘制背景区域
  void drawBg(Canvas canvas, Size size);

  /// 绘制网格
  void drawGrid(Canvas canvas);

  /// 绘制图表
  void drawChart(Canvas canvas, Size size);

  /// 绘制右侧数据
  void drawRightData(Canvas canvas);

  /// 绘制实时价格
  void drawRealTimePrice(Canvas canvas, Size size);

  /// 绘制时间
  void drawDate(Canvas canvas, Size size);

  /// 绘制相关数据
  void drawData(Canvas canvas, KLineModel data, double x);

  /// 绘制最(大小)值
  void drawMost(Canvas canvas);

  /// 绘制交叉线相关数据
  void drawCrossLineData(Canvas canvas, Size size);

  /// 初始化区块的相关数据
  void initRect(Size size) {
    width = size.width;
    displayHeight =
        size.height - ChartStyle.topPadding - ChartStyle.bottomDateHigh;
    rightMargin = (width / ChartStyle.gridColumns - pointGap) / scaleX;
    double volHeight = displayHeight * 0.2,
        mainHeight = displayHeight * 0.6,
        minorHeight = volHeight;

    if (volType == VolType.NONE && minorType == MinorType.NONE) {
      mainHeight = displayHeight;
    } else if (volType == VolType.NONE || minorType == MinorType.NONE) {
      mainHeight = displayHeight * 0.8;
    }

    mainRect = Rect.fromLTRB(
        0, ChartStyle.topPadding, width, ChartStyle.topPadding + mainHeight);

    if (volType != VolType.NONE)
      volRect = Rect.fromLTRB(0, mainRect.bottom + ChartStyle.childPadding,
          width, mainRect.bottom + volHeight);

    if (minorType != MinorType.NONE)
      minorRect = Rect.fromLTRB(
          0,
          (volRect?.bottom ?? mainRect.bottom) + ChartStyle.childPadding,
          width,
          (volRect?.bottom ?? mainRect.bottom) + minorHeight);
  }

  /// 计算各种指标
  void calcVal() {
    if (data == null || data.isEmpty) return;
    maxScrollX = minTranslateX().abs();
    scrollXToTranslateX(scrollX);
    startIndex = indexOfTranslateX(xToTranslateX(0));
    stopIndex = indexOfTranslateX(xToTranslateX(width));
    for (int i = startIndex; i <= stopIndex; i++) {
      calcVolVal(data[i]);
      calcMainVal(data[i], i);
      calcMinorVal(data[i]);
    }
  }

  /// 计算成交量相关指标
  void calcVolVal(KLineModel item) {
    volMaxVal = max(volMaxVal, max(item.vol, max(item.volMA5, item.volMA10)));
    volMinVal = min(volMinVal, min(item.vol, min(item.volMA5, item.volMA10)));
  }

  /// 计算K线相关指标
  void calcMainVal(KLineModel model, int i) {
    if (isLine) {
      mainMaxVal = max(mainMaxVal, model.close);
      mainMinVal = min(mainMinVal, model.close);
    } else {
      double high = model.high, low = model.low;
      if (mainType == MainType.MA) {
        if (model.priceMA5 != 0) {
          low = min(low, model.priceMA5);
          high = max(high, model.priceMA5);
        }
        if (model.priceMA5 != 0) {
          low = min(low, model.priceMA10);
          high = max(high, model.priceMA10);
        }
        if (model.priceMA20 != 0) {
          low = min(low, model.priceMA20);
          high = max(high, model.priceMA20);
        }
        if (model.priceMA30 != 0) {
          low = min(low, model.priceMA30);
          high = max(high, model.priceMA30);
        }
      } else if (mainType == MainType.BOLL) {
        if (model.dn != 0) low = min(model.dn, model.low);
        if (model.up != 0) high = max(model.up, model.high);
      }
      mainMinVal = min(mainMinVal, low);
      mainMaxVal = max(mainMaxVal, high);

      if (mainHighMaxVal < model.high) {
        mainMaxIndex = i;
        mainHighMaxVal = model.high;
      }
      if (mainLowMinVal > model.low) {
        mainMinIndex = i;
        mainLowMinVal = model.low;
      }
    }
  }

  /// 计算次要区块(K线下方区域)相关指标
  void calcMinorVal(KLineModel item) {
    if (minorType == MinorType.MACD) {
      minorMaxVal = max(minorMaxVal, max(item.macd, max(item.dif, item.dea)));
      minorMinVal = min(minorMinVal, min(item.macd, min(item.dif, item.dea)));
    } else if (minorType == MinorType.KDJ) {
      minorMaxVal = max(minorMaxVal, max(item.k, max(item.d, item.j)));
      minorMinVal = min(minorMinVal, min(item.k, min(item.d, item.j)));
    } else if (minorType == MinorType.RSI) {
      minorMaxVal = max(minorMaxVal, item.rsi);
      minorMinVal = min(minorMinVal, item.rsi);
    } else {
      minorMaxVal = max(minorMaxVal, item.r);
      minorMinVal = min(minorMinVal, item.r);
    }
  }

  /// 获取平移的最小值
  double minTranslateX() {
    double x = -dataLenght + width / scaleX - pointGap / 2;
    x = x >= 0 ? 0 : x;
    if (x >= 0) {
      // 数据不足一屏
      if (width / scaleX - getX(data.length) < rightMargin) {
        // 数据填充后剩余空间比[rightMargin]小，求出差。x-=差
        x -= (rightMargin - width / scaleX + getX(data.length));
      } else {
        // 数据填充后剩余空间比[rightMargin]大
        rightMargin = width / scaleX - getX(data.length);
      }
    } else if (x < 0) x -= rightMargin; // 数据超过一屏

    return x >= 0 ? 0 : x;
  }

  /// 根据索引索取x坐标
  /// + pointGap / 2 防止第一根和最后一根k线显示不全
  /// @param index 索引值
  double getX(int index) => index * pointGap + pointGap / 2;

  /// ScrollX 转换为 TranslateX(平移X)
  /// @param sx ScrollX值
  void scrollXToTranslateX(double sx) => translateX = sx + minTranslateX();

  /// 视图坐标X 转换为 TranslateX(平移X)
  /// @param x 坐标X
  double xToTranslateX(double x) => -translateX + x / scaleX;

  /// TranslateX(平移X) 转换为 视图坐标X
  /// @param tx TranslateX(平移X)
  double translateXToX(double tx) => (tx + translateX) * scaleX;

  /// 计算长按后x的值，转换为index
  /// @param sx selecteX选择的X值
  int calcSelecteX(double sx) {
    int index = indexOfTranslateX(xToTranslateX(sx));
    if (index < startIndex) index = startIndex;
    if (index > stopIndex) index = stopIndex;
    return index;
  }

  /// 查找当前值的index
  /// @param tx TranslateX(平移X)
  int indexOfTranslateX(double tx) => _indexOfTranslateX(tx, 0, modelCount - 1);

  /// 二分查找当前值的index
  /// @param tx TranslateX(平移X)
  /// @param s 开始值
  /// @param e 结束值
  int _indexOfTranslateX(double tx, int s, int e) {
    if (e == s || e == -1) return s;

    if (e - s == 1) return (tx - getX(s)).abs() < (tx - getX(e)).abs() ? s : e;

    int m = s + (e - s) ~/ 2; // 二分中间值
    double mv = getX(m);
    if (tx < mv) {
      return _indexOfTranslateX(tx, s, m);
    } else if (tx > mv) {
      return _indexOfTranslateX(tx, m, e);
    } else
      return m;
  }

  /// 获取某一项
  KLineModel model(int index) =>
      (data != null && data.isNotEmpty && data.length != 0)
          ? data[index]
          : null;

  /// 获取TextStyle
  TextStyle textStyle(Color color) =>
      TextStyle(fontSize: ChartStyle.defaultTextSize, color: color);

  /// 数据格式化
  String format(double n, [int p = 4]) => Num.fix(n, p);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
