import 'dart:async';
import 'package:flutter/material.dart';
import '../tools/index.dart';
import '../views/style.dart';
import '../views/chart.dart';
import '../models/index.dart';
import 'base/render.dart';
import 'base/painter.dart';
import 'render/vol.dart';
import 'render/main.dart';
import 'render/minor.dart';

class ChartPainter extends BasePainter {
  double opacity;
  StreamSink<WinInfoModel> sink;
  AnimationController controller;
  BaseRender volRender, mainRender, minorRender;
  static double get maxScrollX => BasePainter.maxScrollX;
  final Paint bgPaint = Paint()..color = ChartColor.bgColor,
      selectPointPaint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 0.5
        ..color = ChartColor.markerBgColor,
      selectorBorderPaint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke
        ..color = ChartColor.markerBorderColor,
      realTimePaint = Paint()
        ..strokeWidth = 1
        ..isAntiAlias = true,
      pointPaint = Paint();

  ChartPainter(
    List<KLineModel> data, {
    this.sink,
    this.controller,
    this.opacity = 0,
    bool isLine,
    VolType volType,
    MainType mainType,
    MinorType minorType,
    @required double scaleX,
    @required double scrollX,
    @required double selectX,
    @required bool isLongPress,
  }) : super(
          data,
          isLine: isLine,
          scaleX: scaleX,
          scrollX: scrollX,
          selectX: selectX,
          volType: volType,
          mainType: mainType,
          minorType: minorType,
          isLongPress: isLongPress,
        );

  @override
  void initRender() {
    mainRender ??= MainRender(
      mainRect,
      isLine: isLine,
      type: mainType,
      maxv: mainMaxVal,
      minv: mainMinVal,
      topPadding: ChartStyle.topPadding,
    );
    if (volRect != null)
      volRender ??= VolRender(
        volRect,
        maxv: volMaxVal,
        minv: volMinVal,
        topPadding: ChartStyle.childPadding,
      );

    if (minorRect != null)
      minorRender ??= MinorRender(
        minorRect,
        type: minorType,
        maxv: minorMaxVal,
        minv: minorMinVal,
        topPadding: ChartStyle.childPadding,
      );
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    if (mainRect != null) {
      Rect rect = Rect.fromLTRB(
          0, 0, mainRect.width, mainRect.height + ChartStyle.topPadding);
      canvas.drawRect(rect, bgPaint);
    }

    if (volRect != null) {
      Rect rect = Rect.fromLTRB(0, volRect.top - ChartStyle.childPadding,
          volRect.width, volRect.bottom);
      canvas.drawRect(rect, bgPaint);
    }

    if (minorRect != null) {
      Rect rect = Rect.fromLTRB(0, minorRect.top - ChartStyle.childPadding,
          minorRect.width, minorRect.bottom);
      canvas.drawRect(rect, bgPaint);
    }
    Rect dateRect = Rect.fromLTRB(
        0, size.height - ChartStyle.bottomDateHigh, size.width, size.height);
    canvas.drawRect(dateRect, bgPaint);
  }

  @override
  void drawGrid(Canvas canvas) {
    mainRender?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    volRender?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    minorRender?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(translateX * scaleX, 0);
    canvas.scale(scaleX, 1);
    for (int i = startIndex; data != null && i <= stopIndex; i++) {
      KLineModel curPoint = data[i];
      if (curPoint == null) continue;
      KLineModel lastPoint = i == 0 ? curPoint : data[i - 1];
      double curX = getX(i), lastX = i == 0 ? curX : getX(i - 1);
      mainRender?.drawChart(canvas, size, lastPoint, curPoint, lastX, curX);
      volRender?.drawChart(canvas, size, lastPoint, curPoint, lastX, curX);
      minorRender?.drawChart(canvas, size, lastPoint, curPoint, lastX, curX);
    }
    if (isLongPress) _drawCrossLine(canvas, size);
    canvas.restore();
  }

  @override
  void drawData(Canvas canvas, KLineModel data, double x) {
    // 长按显示按中的数据
    if (isLongPress) data = model(calcSelecteX(selectX));
    // 松开显示最后一条数据
    mainRender?.drawData(canvas, data, x);
    volRender?.drawData(canvas, data, x);
    minorRender?.drawData(canvas, data, x);
  }

  @override
  void drawRightData(Canvas canvas) {
    TextStyle style = textStyle(ChartColor.yAxisTextColor);
    mainRender?.drawRightData(canvas, style, ChartStyle.gridRows);
    volRender?.drawRightData(canvas, style, ChartStyle.gridRows);
    minorRender?.drawRightData(canvas, style, ChartStyle.gridRows);
  }

  @override
  void drawCrossLineData(Canvas canvas, Size size) {
    int index = calcSelecteX(selectX);
    KLineModel point = model(index);
    TextPainter tp = textPainter(format(point.close), Colors.white);
    bool isLeft = false;
    double textHeight = tp.height,
        textWidth = tp.width,
        w1 = 5,
        w2 = 3,
        r = textHeight / 2 + w2,
        x,
        y = getMainY(point.close);

    if (translateXToX(getX(index)) < width / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = width - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(width - 2, y + r);
      path.lineTo(width - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter date = textPainter(timeFormat(point.id));
    textWidth = date.width;
    r = textHeight / 2;
    x = translateXToX(getX(index));
    y = size.height - ChartStyle.bottomDateHigh;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (width - x < textWidth + 2 * w1)
      x = width - 1 - textWidth / 2 - w1;

    double baseLine = textHeight / 2;
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectPointPaint);
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectorBorderPaint);

    date.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(WinInfoModel(point, left: isLeft));
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double space = size.width / ChartStyle.gridColumns,
        startX = getX(startIndex) - pointGap / 2,
        stopX = getX(stopIndex) + pointGap / 2;
    double y = 0;
    for (var i = 0; i <= ChartStyle.gridColumns; ++i) {
      double tx = xToTranslateX(space * i);
      if (tx >= startX && tx <= stopX) {
        int index = indexOfTranslateX(tx);
        if (data[index] == null) continue;
        TextPainter tp =
            textPainter(timeFormat(data[index].id), ChartColor.xAxisTextColor);
        y = size.height -
            (ChartStyle.bottomDateHigh - tp.height) / 2 -
            tp.height;
        tp.paint(canvas, Offset(space * i - tp.width / 2, y));
      }
    }
  }

  @override
  void drawMost(Canvas canvas) {
    if (isLine) return;
    // 绘制最大值和最小值
    double x = translateXToX(getX(mainMinIndex)), y = getMainY(mainLowMinVal);
    if (x < width / 2) {
      // 画右边
      TextPainter tp = textPainter(
          '── ${format(mainLowMinVal)}', ChartColor.maxMinTextColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = textPainter(
          '${format(mainLowMinVal)} ──', ChartColor.maxMinTextColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
    x = translateXToX(getX(mainMaxIndex));
    y = getMainY(mainHighMaxVal);
    if (x < width / 2) {
      //画右边
      TextPainter tp = textPainter(
          '── ${format(mainHighMaxVal)}', ChartColor.maxMinTextColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = textPainter(
          '${format(mainHighMaxVal)} ──', ChartColor.maxMinTextColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  @override
  void drawRealTimePrice(Canvas canvas, Size size) {
    if (rightMargin == 0 || data == null || data.isEmpty) return;
    KLineModel point = data.last;
    TextPainter tp =
        textPainter(format(point.close), ChartColor.rightRealTimeTextColor);
    double y = getMainY(point.close),
        max = (translateX.abs() +
                rightMargin -
                minTranslateX().abs() +
                pointGap) *
            scaleX, // max越往右边滑值越小
        x = width - max;
    if (!isLine) x += pointGap / 2;
    double dashWidth = 10, dashSpace = 5, startX = 0;
    final double space = (dashSpace + dashWidth);
    if (tp.width < max) {
      while (startX < max) {
        canvas.drawLine(
            Offset(x + startX, y),
            Offset(x + startX + dashWidth, y),
            realTimePaint..color = ChartColor.realTimeLineColor);
        startX += space;
      }
      // 闪动效果
      if (isLine) {
        _startAnimation();
        Gradient pointGradient = RadialGradient(colors: [
          Colors.white.withOpacity(opacity ?? 0),
          Colors.transparent
        ]);
        pointPaint.shader = pointGradient
            .createShader(Rect.fromCircle(center: Offset(x, y), radius: 14));
        canvas.drawCircle(Offset(x, y), 14, pointPaint);
        canvas.drawCircle(Offset(x, y), 2, realTimePaint..color = Colors.white);
      } else
        _stopAnimation();

      double left = width - tp.width, top = y - tp.height / 2;
      canvas.drawRect(
          Rect.fromLTRB(left, top, left + tp.width, top + tp.height),
          realTimePaint..color = ChartColor.realTimeBgColor);
      tp.paint(canvas, Offset(left, top));
    } else {
      _stopAnimation(); //停止一闪闪
      startX = 0;
      if (point.close > mainMaxVal) {
        y = getMainY(mainMaxVal);
      } else if (point.close < mainMinVal) {
        y = getMainY(mainMinVal);
      }
      while (startX < width) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y),
            realTimePaint..color = ChartColor.realTimeLongLineColor);
        startX += space;
      }

      const double padding = 3,
          triangleHeight = 8, //三角高度
          triangleWidth = 5; //三角宽度

      double left =
          width - width / ChartStyle.gridColumns - tp.width / 2 - padding * 2;
      double top = y - tp.height / 2 - padding;
      // 加上三角形的宽以及padding
      double right = left + tp.width + padding * 2 + triangleWidth + padding;
      double bottom = top + tp.height + padding * 2,
          radius = (bottom - top) / 2;
      //画椭圆背景
      RRect rectBg1 = RRect.fromLTRBR(
              left, top, right, bottom, Radius.circular(radius)),
          rectBg2 = RRect.fromLTRBR(left - 1, top - 1, right + 1, bottom + 1,
              Radius.circular(radius + 2));
      canvas.drawRRect(
          rectBg2, realTimePaint..color = ChartColor.realTimeTextBorderColor);
      canvas.drawRRect(
          rectBg1, realTimePaint..color = ChartColor.realTimeBgColor);
      tp = textPainter(format(point.close), ChartColor.realTimeTextColor);
      Offset textOffset = Offset(left + padding, y - tp.height / 2);
      tp.paint(canvas, textOffset);
      // 画三角
      Path path = Path();
      double dx = tp.width + textOffset.dx + padding,
          dy = top + (bottom - top - triangleHeight) / 2;
      path.moveTo(dx, dy);
      path.lineTo(dx + triangleWidth, dy + triangleHeight / 2);
      path.lineTo(dx, dy + triangleHeight);
      path.close();
      canvas.drawPath(
        path,
        realTimePaint
          ..color = ChartColor.realTimeTextColor
          ..shader = null,
      );
    }
  }

  /// 画交叉线
  void _drawCrossLine(Canvas canvas, Size size) {
    int index = calcSelecteX(selectX);
    KLineModel point = model(index);
    Paint paintY = Paint()
      ..color = Colors.white12
      ..strokeWidth = ChartStyle.vCrossWidth
      ..isAntiAlias = true;
    double x = getX(index), y = getMainY(point.close);
    // K线图竖线
    canvas.drawLine(Offset(x, ChartStyle.topPadding),
        Offset(x, size.height - ChartStyle.bottomDateHigh), paintY);

    Paint paintX = Paint()
      ..color = Colors.white
      ..strokeWidth = ChartStyle.hCrossWidth
      ..isAntiAlias = true;
    // K线图横线
    canvas.drawLine(Offset(-translateX, y),
        Offset(-translateX + width / scaleX, y), paintX);
    canvas.drawCircle(Offset(x, y), 2, paintX);
  }

  /// 获取主视图的Y坐标
  double getMainY(double y) => mainRender?.getY(y) ?? 0;

  TextPainter textPainter(String text, [color = Colors.white]) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: textStyle(color)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  /// 时间格式化
  String timeFormat(int t) => Date.format(t, timeFmt);

  void _startAnimation() {
    if (controller?.isAnimating != true) controller?.repeat(reverse: true);
  }

  void _stopAnimation() {
    if (controller?.isAnimating == true) controller?.stop();
  }
}
