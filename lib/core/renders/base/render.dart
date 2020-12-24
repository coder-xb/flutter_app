import 'package:flutter/material.dart';
import '../../tools/index.dart';
import '../../views/style.dart';

abstract class BaseRender<T> {
  Rect rect;
  double minv, maxv, scaleY, topPadding;

  BaseRender(
    this.rect, {
    @required this.maxv,
    @required this.minv,
    @required this.topPadding,
  }) {
    if (maxv == minv) {
      minv -= 0.5;
      maxv += 0.5;
    }
    scaleY = rect.height / (maxv - minv);
  }

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = ChartColor.chartColor;

  final Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = ChartColor.gridColor;

  /// 获取y坐标
  double getY(double y) => (maxv - y) * scaleY + rect.top;

  /// 数据格式化
  String format(double n, [int p = 2]) => Num.fix(n, p);

  /// 绘制网格
  void drawGrid(Canvas canvas, int rows, int cols);

  /// 绘制数据
  void drawData(Canvas canvas, T data, double x);

  /// 绘制右侧数据
  void drawRightData(Canvas canvas, TextStyle style, int rows);

  /// 绘制图表
  void drawChart(Canvas canvas, Size size, T lastPoint, T curPoint,
      double lastX, double curX);

  /// 绘制线条
  void drawLine(Canvas canvas, double lastPrice, double curPrice, double lastX,
      double curX, Color color) {
    double lastY = getY(lastPrice), curY = getY(curPrice);
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color);
  }

  /// 获取TextStyle
  TextStyle textStyle(Color color) =>
      TextStyle(fontSize: ChartStyle.defaultTextSize, color: color);
}
