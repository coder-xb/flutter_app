import 'dart:math';
import 'package:flutter/material.dart';
import '../base/render.dart';
import '../../views/chart.dart';
import '../../views/style.dart';
import '../../models/index.dart';

class MainRender extends BaseRender<CandleMixin> {
  final bool isLine;
  final MainType type;
  double _contentPadding = 12,
      candleWidth = ChartStyle.candleWidth,
      candleLineWidth = ChartStyle.candleLineWidth;

  MainRender(
    Rect rect, {
    @required this.type,
    @required this.isLine,
    @required double maxv,
    @required double minv,
    @required double topPadding,
  }) : super(rect, maxv: maxv, minv: minv, topPadding: topPadding) {
    double diff = maxv - minv, // 计算差
        newScaleY = (rect.height - _contentPadding) / diff, // 新缩放比例 = 内容高度 / 差
        newDiff = rect.height / newScaleY, // 新的差 = 高 / 新缩放比例
        val = (newDiff - diff) / 2; // Y轴需扩大的值 = (新差 - 差) / 2
    if (newDiff > diff) {
      this.maxv += val;
      this.minv -= val;
      this.scaleY = newScaleY;
    }
  }

  Shader lineFillShader;
  Path linePath, lineFillPath;
  Paint linePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..color = ChartColor.kLineColor;
  Paint lineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void drawData(Canvas canvas, CandleMixin data, double x) {
    if (isLine) return;
    TextSpan span;
    if (type == MainType.MA) {
      List<TextSpan> children = List<TextSpan>();
      if (data.priceMA5 != 0)
        children.add(TextSpan(
          text: 'MA5:${format(data.priceMA5)}    ',
          style: textStyle(ChartColor.ma5Color),
        ));
      if (data.priceMA10 != 0)
        children.add(TextSpan(
          text: 'MA10:${format(data.priceMA10)}    ',
          style: textStyle(ChartColor.ma10Color),
        ));
      if (data.priceMA30 != 0)
        children.add(TextSpan(
          text: 'MA30:${format(data.priceMA30)}    ',
          style: textStyle(ChartColor.ma30Color),
        ));
      span = TextSpan(children: children);
    } else if (type == MainType.BOLL) {
      List<TextSpan> children = List<TextSpan>();
      if (data.mb != 0)
        children.add(TextSpan(
          text: 'BOLL:${format(data.mb)}    ',
          style: textStyle(ChartColor.ma5Color),
        ));
      if (data.up != 0)
        children.add(TextSpan(
          text: 'UP:${format(data.up)}    ',
          style: textStyle(ChartColor.ma10Color),
        ));
      if (data.dn != 0)
        children.add(TextSpan(
          text: 'LB:${format(data.dn)}    ',
          style: textStyle(ChartColor.ma30Color),
        ));
      span = TextSpan(children: children);
    }
    if (span == null) return;
    TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(x, rect.top - topPadding));
  }

  @override
  void drawChart(Canvas canvas, Size size, CandleMixin lastPoint,
      CandleMixin curPoint, double lastX, double curX) {
    if (!isLine) _drawCandle(canvas, curPoint, curX);
    if (isLine) {
      _drawLine(canvas, lastPoint.close, curPoint.close, lastX, curX);
    } else if (type == MainType.MA) {
      _drawMaLine(canvas, lastPoint, curPoint, lastX, curX);
    } else if (type == MainType.BOLL)
      _drawBollLine(canvas, lastPoint, curPoint, lastX, curX);
  }

  @override
  void drawGrid(Canvas canvas, int rows, int cols) {
    double rowSpace = rect.height / rows;
    for (int i = 0; i <= rows; i++)
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(rect.width, rowSpace * i + topPadding), gridPaint);

    double colSpace = rect.width / cols;
    for (int i = 0; i <= colSpace; i++)
      canvas.drawLine(Offset(colSpace * i, topPadding / 3),
          Offset(colSpace * i, rect.bottom), gridPaint);
  }

  @override
  void drawRightData(Canvas canvas, TextStyle style, int rows) {
    double space = rect.height / rows;
    for (int i = 0; i <= rows; ++i) {
      double pos = 0;
      if (i == 0) {
        pos = (rows - i) * space - _contentPadding / 2;
      } else if (i == rows) {
        pos = (rows - i) * space + _contentPadding / 2;
      } else
        pos = (rows - i) * space;

      double val = pos / scaleY + minv;
      TextPainter tp = TextPainter(
        text: TextSpan(text: "${format(val)}", style: style),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      double posy = (i == 0 || i == rows)
          ? (getY(val) - tp.height / 2)
          : (getY(val) - tp.height);
      tp.paint(canvas, Offset(rect.width - tp.width, posy));
    }
  }

  void _drawCandle(Canvas canvas, CandleMixin point, double curX) {
    double low = getY(point.low),
        high = getY(point.high),
        open = getY(point.open),
        close = getY(point.close),
        r = candleWidth / 2,
        lr = candleLineWidth / 2;

    chartPaint.color = open > close ? ChartColor.upColor : ChartColor.dnColor;
    canvas.drawRect(
        Rect.fromLTRB(curX - r, min(open, close), curX + r, max(open, close)),
        chartPaint);
    canvas.drawRect(Rect.fromLTRB(curX - lr, high, curX + lr, low), chartPaint);
  }

  void _drawLine(Canvas canvas, double lastPrice, double curPrice, double lastX,
      double curX) {
    linePath ??= Path();
    if (lastX == curX) lastX = 0; // 起点位置填充
    linePath.moveTo(lastX, getY(lastPrice));
    linePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

    /// 画阴影
    lineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: ChartColor.kLineShadowColor,
    ).createShader(Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom));
    lineFillPaint..shader = lineFillShader;

    lineFillPath ??= Path();
    lineFillPath.moveTo(lastX, rect.height + rect.top);
    lineFillPath.lineTo(lastX, getY(lastPrice));
    lineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    lineFillPath.lineTo(curX, rect.height + rect.top);
    lineFillPath.close();

    canvas.drawPath(lineFillPath, lineFillPaint);
    lineFillPath.reset();
    canvas.drawPath(linePath, linePaint);
    linePath.reset();
  }

  void _drawMaLine(Canvas canvas, CandleMixin lastPoint, CandleMixin curPoint,
      double lastX, double curX) {
    if (lastPoint.priceMA5 != 0)
      drawLine(canvas, lastPoint.priceMA5, curPoint.priceMA5, lastX, curX,
          ChartColor.ma5Color);
    if (lastPoint.priceMA10 != 0)
      drawLine(canvas, lastPoint.priceMA10, curPoint.priceMA10, lastX, curX,
          ChartColor.ma10Color);
    if (lastPoint.priceMA30 != 0)
      drawLine(canvas, lastPoint.priceMA30, curPoint.priceMA30, lastX, curX,
          ChartColor.ma30Color);
  }

  void _drawBollLine(Canvas canvas, CandleMixin lastPoint, CandleMixin curPoint,
      double lastX, double curX) {
    if (lastPoint.up != 0)
      drawLine(
          canvas, lastPoint.up, curPoint.up, lastX, curX, ChartColor.ma10Color);
    if (lastPoint.mb != 0)
      drawLine(
          canvas, lastPoint.mb, curPoint.mb, lastX, curX, ChartColor.ma5Color);
    if (lastPoint.dn != 0)
      drawLine(
          canvas, lastPoint.dn, curPoint.dn, lastX, curX, ChartColor.ma30Color);
  }
}
