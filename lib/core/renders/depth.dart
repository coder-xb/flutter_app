import 'dart:math';
import 'package:flutter/material.dart';
import '../tools/index.dart';
import '../models/index.dart';
import '../views/style.dart';

class DepthPainter extends CustomPainter {
  /// 买入/卖出
  List<DepthModel> buys, sells;
  Offset pressOffset;
  bool isLongPress;

  double bottomPadding = 18,
      width = 0,
      drawHeight = 0,
      drawWidth = 0,
      buyPointGap, // 点点间隙
      sellPointGap, // 点点间隙
      maxVol, // 最大的委托量
      multiple;

  /// 右侧绘制个数
  int lineCount = 4, lastPos;
  Path buyPath, sellPath;

  /// 买卖出区域边线/买卖出区域
  Paint buyLinePaint,
      sellLinePaint,
      buyPathPaint,
      sellPathPaint,
      selectPaint = Paint()
        ..isAntiAlias = true
        ..color = ChartColor.markerBgColor,
      selectBorderPaint = Paint()
        ..isAntiAlias = true
        ..color = ChartColor.markerBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

  DepthPainter(
    this.buys,
    this.sells, {
    this.pressOffset,
    this.isLongPress,
  }) {
    buyLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = ChartColor.depthBuyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    sellLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = ChartColor.depthSellColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    buyPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = ChartColor.depthBuyColor.withOpacity(0.2);
    sellPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = ChartColor.depthSellColor.withOpacity(0.2);
    buyPath ??= Path();
    sellPath ??= Path();
    init();
  }

  void init() {
    if (buys == null || sells == null || buys.isEmpty || sells.isEmpty) return;
    maxVol = buys[0].amount;
    maxVol = max(maxVol, sells.last.amount);
    maxVol = maxVol * 1.05;
    multiple = maxVol / lineCount;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (buys == null || sells == null || buys.isEmpty || sells.isEmpty) return;
    width = size.width;
    drawWidth = width / 2;
    drawHeight = size.height - bottomPadding;
    canvas.save();
    // 绘制买入区域
    _drawBuy(canvas);
    // 绘制卖出区域
    _drawSell(canvas);
    // 绘制界面相关数据显示
    _drawData(canvas);
    canvas.restore();
  }

  void _drawBuy(Canvas canvas) {
    int len = buys.length;
    double x, y;
    buyPointGap = (drawWidth / (len - 1 == 0 ? 1 : len - 1));
    buyPath.reset();
    for (int i = 0; i < len; i++) {
      x = buyPointGap * i;
      y = getY(buys[i].amount);
      if (i == 0) buyPath.moveTo(0, y);

      if (i > 0)
        canvas.drawLine(Offset(buyPointGap * (i - 1), getY(buys[i - 1].amount)),
            Offset(x, y), buyLinePaint);

      if (i != len - 1)
        buyPath.quadraticBezierTo(
            x, y, buyPointGap * (i + 1), getY(buys[i + 1].amount));

      if (i == len - 1) {
        buyPath.quadraticBezierTo(x, y, x, drawHeight);
        buyPath.quadraticBezierTo(x, drawHeight, 0, drawHeight);
        buyPath.close();
      }
    }
    canvas.drawPath(buyPath, buyPathPaint);
  }

  void _drawSell(Canvas canvas) {
    int len = sells.length;
    double x, y;
    sellPointGap = (drawWidth / (len - 1 == 0 ? 1 : len - 1));
    sellPath.reset();
    for (int i = 0; i < len; i++) {
      x = sellPointGap * i + drawWidth;
      y = getY(sells[i].amount);
      if (i == 0) sellPath.moveTo(drawWidth, y);

      if (i > 0)
        canvas.drawLine(
            Offset(
                sellPointGap * (i - 1) + drawWidth, getY(sells[i - 1].amount)),
            Offset(x, y),
            sellLinePaint);

      if (i != len - 1)
        sellPath.quadraticBezierTo(x, y, (sellPointGap * (i + 1)) + drawWidth,
            getY(sells[i + 1].amount));

      if (i == len - 1) {
        sellPath.quadraticBezierTo(width, y, x, drawHeight);
        sellPath.quadraticBezierTo(x, drawHeight, drawWidth, drawHeight);
        sellPath.close();
      }
    }
    canvas.drawPath(sellPath, sellPathPaint);
  }

  void _drawData(Canvas canvas) {
    double val;
    String str;
    for (int i = 0; i < lineCount; i++) {
      val = maxVol - multiple * i;
      str = Num.fix(val);
      TextPainter tp = textPainter(str);
      tp.layout();
      tp.paint(canvas,
          Offset(width - tp.width, drawHeight / lineCount * i + tp.height / 2));
    }
    TextPainter start = textPainter(Num.fix(buys.first.price));
    start.paint(canvas, Offset(0, bottomTextY(start.height)));

    TextPainter center = textPainter(
        Num.fix(Num.div(Num.add(buys.last.price, sells.first.price), 2)));
    center.paint(canvas,
        Offset(drawWidth - center.width / 2, bottomTextY(center.height)));

    TextPainter end = textPainter(Num.fix(sells.last.price));
    end.paint(canvas, Offset(width - end.width, bottomTextY(end.height)));

    if (isLongPress) {
      int index = pressOffset.dx <= drawWidth
          ? _indexOfTranslateX(pressOffset.dx, 0, buys.length, getBuyX)
          : _indexOfTranslateX(pressOffset.dx, 0, sells.length, getSellX);
      _drawSelect(canvas, index, pressOffset.dx <= drawWidth);
    }
  }

  void _drawSelect(Canvas canvas, int index, bool isLeft) {
    DepthModel model = isLeft ? buys[index] : sells[index];
    double dx = isLeft ? getBuyX(index) : getSellX(index), radius = 8;
    if (dx < drawWidth) {
      canvas.drawCircle(Offset(dx, getY(model.amount)), radius / 3,
          buyLinePaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(model.amount)), radius,
          buyLinePaint..style = PaintingStyle.stroke);
    } else {
      canvas.drawCircle(Offset(dx, getY(model.amount)), radius / 3,
          sellLinePaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(model.amount)), radius,
          sellLinePaint..style = PaintingStyle.stroke);
    }

    /// 画底部
    double left;
    TextPainter price = textPainter(Num.fix(model.price));
    if (dx <= price.width / 2) {
      left = 0;
    } else if (dx >= width - price.width / 2) {
      left = width - price.width;
    } else {
      left = dx - price.width / 2;
    }
    Rect bottomRect = Rect.fromLTRB(left - 3, drawHeight + 3,
        left + price.width + 3, drawHeight + bottomPadding);
    canvas.drawRect(bottomRect, selectPaint);
    canvas.drawRect(bottomRect, selectBorderPaint);
    price.paint(
        canvas,
        Offset(bottomRect.left + (bottomRect.width - price.width) / 2,
            bottomRect.top + (bottomRect.height - price.height) / 2));

    /// 画左边
    double y = getY(model.amount), rightRectTop;
    TextPainter amount = textPainter(Num.fix(model.amount));
    if (y <= amount.height / 2) {
      rightRectTop = 0;
    } else if (y >= drawHeight - amount.height / 2) {
      rightRectTop = drawHeight - amount.height;
    } else {
      rightRectTop = y - amount.height / 2;
    }
    Rect rightRect = Rect.fromLTRB(width - amount.width - 6, rightRectTop - 3,
        width, rightRectTop + amount.height + 3);
    canvas.drawRect(rightRect, selectPaint);
    canvas.drawRect(rightRect, selectBorderPaint);
    amount.paint(
        canvas,
        Offset(rightRect.left + (rightRect.width - amount.width) / 2,
            rightRect.top + (rightRect.height - amount.height) / 2));
  }

  /// 二分查找当前值的index
  /// @param tx TranslateX(平移X)
  /// @param s 开始值
  /// @param e 结束值
  /// @param getx 获取X的函数
  int _indexOfTranslateX(double tx, int s, int e, Function getx) {
    if (e == s || e == -1) return s;

    if (e - s == 1) return (tx - getx(s)).abs() < (tx - getx(e)).abs() ? s : e;

    int m = s + (e - s) ~/ 2; // 二分中间值
    double mv = getx(m);
    if (tx < mv) {
      return _indexOfTranslateX(tx, s, m, getx);
    } else if (tx > mv) {
      return _indexOfTranslateX(tx, m, e, getx);
    } else
      return m;
  }

  /// 根据索引获取x
  double getBuyX(int index) => index * buyPointGap;
  double getSellX(int index) => index * sellPointGap + drawWidth;

  /// 获取Y
  double getY(double vol) => drawHeight - (drawHeight) * vol / maxVol;
  double bottomTextY(double h) => (bottomPadding - h) / 2 + drawHeight;

  TextPainter textPainter(String text, [color = Colors.white]) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(DepthPainter oldDelegate) => true;
}
