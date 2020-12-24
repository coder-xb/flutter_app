import 'package:flutter/material.dart';
import '../base/render.dart';
import '../../views/chart.dart';
import '../../views/style.dart';
import '../../models/index.dart';

class MinorRender extends BaseRender<MACDMixin> {
  double width = ChartStyle.macdWidth;
  MinorType type;

  MinorRender(
    Rect rect, {
    @required this.type,
    @required double maxv,
    @required double minv,
    @required double topPadding,
  }) : super(rect, maxv: maxv, minv: minv, topPadding: topPadding);

  @override
  void drawData(Canvas canvas, MACDMixin data, double x) {
    List<TextSpan> children = List<TextSpan>();
    if (type == MinorType.MACD) {
      children = [
        TextSpan(
          text: 'MACD(12,26,9)    ',
          style: textStyle(ChartColor.yAxisTextColor),
        )
      ];
      if (data.macd != 0)
        children.add(TextSpan(
          text: 'MACD:${format(data.macd)}    ',
          style: textStyle(ChartColor.macdColor),
        ));
      if (data.dif != 0)
        children.add(TextSpan(
          text: 'DIF:${format(data.dif)}    ',
          style: textStyle(ChartColor.difColor),
        ));
      if (data.dea != 0)
        children.add(TextSpan(
          text: 'DEA:${format(data.dea)}    ',
          style: textStyle(ChartColor.deaColor),
        ));
    } else if (type == MinorType.KDJ) {
      children = [
        TextSpan(
          text: 'KDJ(14,1,3)    ',
          style: textStyle(ChartColor.yAxisTextColor),
        )
      ];
      if (data.k != 0)
        children.add(TextSpan(
          text: 'K:${format(data.k)}    ',
          style: textStyle(ChartColor.kColor),
        ));
      if (data.d != 0)
        children.add(TextSpan(
          text: 'D:${format(data.d)}    ',
          style: textStyle(ChartColor.dColor),
        ));
      if (data.j != 0)
        children.add(TextSpan(
          text: 'J:${format(data.j)}    ',
          style: textStyle(ChartColor.jColor),
        ));
    } else if (type == MinorType.RSI) {
      children = [
        TextSpan(
          text: 'RSI(14):${format(data.rsi)}    ',
          style: textStyle(ChartColor.rsiColor),
        )
      ];
    } else if (type == MinorType.WR) {
      children = [
        TextSpan(
          text: 'WR(14):${format(data.r)}    ',
          style: textStyle(ChartColor.rsiColor),
        )
      ];
    }
    TextPainter(
      text: TextSpan(children: children),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x, rect.top - topPadding));
  }

  @override
  void drawChart(Canvas canvas, Size size, MACDMixin lastPoint,
      MACDMixin curPoint, double lastX, double curX) {
    if (type == MinorType.MACD) {
      _drawMACD(canvas, lastPoint, curPoint, lastX, curX);
    } else if (type == MinorType.KDJ) {
      if (lastPoint.k != 0)
        drawLine(
            canvas, lastPoint.k, curPoint.k, lastX, curX, ChartColor.kColor);
      if (lastPoint.d != 0)
        drawLine(
            canvas, lastPoint.d, curPoint.d, lastX, curX, ChartColor.dColor);
      if (lastPoint.j != 0)
        drawLine(
            canvas, lastPoint.j, curPoint.j, lastX, curX, ChartColor.jColor);
    } else if (type == MinorType.RSI) {
      if (lastPoint.rsi != 0)
        drawLine(canvas, lastPoint.rsi, curPoint.rsi, lastX, curX,
            ChartColor.rsiColor);
    } else if (type == MinorType.WR) {
      if (lastPoint.r != 0)
        drawLine(
            canvas, lastPoint.r, curPoint.r, lastX, curX, ChartColor.rsiColor);
    }
  }

  @override
  void drawGrid(Canvas canvas, int rows, int cols) {
    canvas.drawLine(
        Offset(0, rect.bottom), Offset(rect.width, rect.bottom), gridPaint);
    double space = rect.width / cols;
    // MinorRect垂直线
    for (int i = 0; i <= space; i++)
      canvas.drawLine(Offset(space * i, rect.top - topPadding),
          Offset(space * i, rect.bottom), gridPaint);
  }

  @override
  void drawRightData(Canvas canvas, TextStyle style, int rows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: '${format(maxv)}', style: style),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: '${format(minv)}', style: style),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(
        canvas, Offset(rect.width - maxTp.width, rect.top - topPadding));
    minTp.paint(
        canvas, Offset(rect.width - minTp.width, rect.bottom - minTp.height));
  }

  void _drawMACD(Canvas canvas, MACDMixin lastPoint, MACDMixin curPoint,
      double lastX, double curX) {
    double macd = getY(curPoint.macd), r = width / 2, zero = getY(0);
    chartPaint.color =
        curPoint.macd > 0 ? ChartColor.upColor : ChartColor.dnColor;
    canvas.drawRect(
        Rect.fromLTRB(curX - r, curPoint.macd > 0 ? macd : zero, curX + r,
            curPoint.macd > 0 ? zero : macd),
        chartPaint);
    if (lastPoint.dif != 0)
      drawLine(canvas, lastPoint.dif, curPoint.dif, lastX, curX,
          ChartColor.difColor);

    if (lastPoint.dea != 0)
      drawLine(canvas, lastPoint.dea, curPoint.dea, lastX, curX,
          ChartColor.deaColor);
  }
}
