import 'package:flutter/material.dart';
import '../base/render.dart';
import '../../tools/index.dart';
import '../../views/style.dart';
import '../../models/index.dart';

class VolRender extends BaseRender<VolMinxin> {
  double width = ChartStyle.volWidth;

  VolRender(
    Rect rect, {
    @required double maxv,
    @required double minv,
    @required double topPadding,
  }) : super(rect, maxv: maxv, minv: minv, topPadding: topPadding);

  @override
  double y(double y) {
    if (maxv == 0) return rect.bottom;
    return (maxv - y) * (rect.height / maxv) + rect.top;
  }

  @override
  void drawChart(Canvas canvas, Size size, VolMinxin lastPoint,
      VolMinxin curPoint, double lastX, double curX) {
    double r = width / 2, top = y(curPoint.vol), bottom = rect.bottom;
    chartPaint.color = curPoint.close >= curPoint.open
        ? ChartColor.upColor
        : ChartColor.dnColor;
    canvas.drawRect(Rect.fromLTRB(curX - r, top, curX + r, bottom), chartPaint);

    if (lastPoint.volMA5 != 0)
      drawLine(canvas, lastPoint.volMA5, curPoint.volMA5, lastX, curX,
          ChartColor.ma5Color);

    if (lastPoint.volMA10 != 0)
      drawLine(canvas, lastPoint.volMA10, curPoint.volMA10, lastX, curX,
          ChartColor.ma10Color);
  }

  @override
  void drawData(Canvas canvas, VolMinxin data, double x) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
            text: 'VOL:${Num.vol(data.vol)}    ',
            style: textStyle(ChartColor.volColor)),
        TextSpan(
            text: 'MA5:${Num.vol(data.volMA5)}    ',
            style: textStyle(ChartColor.ma5Color)),
        TextSpan(
            text: 'MA10:${Num.vol(data.volMA10)}    ',
            style: textStyle(ChartColor.ma10Color)),
      ],
    );
    TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(x, rect.top - topPadding));
  }

  @override
  void drawRightData(Canvas canvas, TextStyle style, int rows) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: '${Num.vol(maxv)}', style: style),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(rect.width - tp.width, rect.top - topPadding));
  }

  @override
  void drawGrid(Canvas canvas, int rows, int cols) {
    canvas.drawLine(
        Offset(0, rect.bottom), Offset(rect.width, rect.bottom), gridPaint);
    double space = rect.width / cols;
    // vol垂直线
    for (int i = 0; i <= space; i++)
      canvas.drawLine(Offset(space * i, rect.top - topPadding),
          Offset(space * i, rect.bottom), gridPaint);
  }
}
