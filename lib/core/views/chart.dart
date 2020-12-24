import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/renders/base/render.dart';
import 'style.dart';
import '../tools/index.dart';
import '../renders/index.dart';
import '../models/index.dart';

enum MainType { MA, BOLL, NONE }
enum MinorType { MACD, KDJ, RSI, WR, NONE }
enum VolType { VOL, NONE }

class KChart extends StatefulWidget {
  final bool isLine;
  final VolType volType;
  final MainType mainType;
  final MinorType minorType;
  final List<KLineModel> data;

  KChart(
    this.data, {
    this.isLine,
    this.volType = VolType.VOL,
    this.mainType = MainType.MA,
    this.minorType = MinorType.MACD,
  });

  @override
  _KChartState createState() => _KChartState();
}

class _KChartState extends State<KChart> with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  StreamController<WinInfoModel> _infoStream;
  double width = 0, scaleX = 0, scrollX = 0, selectX = 0, _lastScale = 0;
  double get minScrollX => scaleX;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    _infoStream = StreamController<WinInfoModel>();
    _controller =
        AnimationController(duration: Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller)
      ..addListener(_notifyChanged);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(KChart oldWidget) {
    if (oldWidget.data != widget.data) scrollX = selectX = 0;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _infoStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || widget.data.isEmpty) {
      scrollX = selectX = 0;
      scaleX = 1;
    }
    return GestureDetector(
      onHorizontalDragDown: (DragDownDetails details) => isDrag = true,
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (isScale || isLongPress) return;
        scrollX = (details.primaryDelta / scaleX + scrollX)
            .clamp(0, BasePainter.maxScrollX)
            .toDouble();
        _notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) => isDrag = false,
      onHorizontalDragCancel: () => isDrag = false,
      onScaleStart: (ScaleStartDetails details) => isScale = true,
      onScaleUpdate: (ScaleUpdateDetails details) {
        if (isDrag || isLongPress) return;
        scaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        _notifyChanged();
      },
      onScaleEnd: (ScaleEndDetails details) {
        _lastScale = scaleX;
        isScale = false;
      },
      onLongPressStart: (LongPressStartDetails details) {
        isLongPress = true;
        if (selectX != details.globalPosition.dx) {
          selectX = details.globalPosition.dx;
          _notifyChanged();
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (selectX != details.globalPosition.dx) {
          selectX = details.globalPosition.dx;
          _notifyChanged();
        }
      },
      onLongPressEnd: (LongPressEndDetails details) {
        isLongPress = false;
        _infoStream?.sink?.add(null);
        _notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: ChartPainter(
              widget.data,
              scaleX: scaleX,
              scrollX: scrollX,
              selectX: selectX,
              isLongPress: isLongPress,
              volType: widget.volType,
              mainType: widget.mainType,
              minorType: widget.minorType,
              isLine: widget.isLine,
              sink: _infoStream?.sink,
              opacity: _animation.value,
              controller: _controller,
            ),
          ),
          _builder(),
        ],
      ),
    );
  }

  void _notifyChanged() => setState(() {});

  StreamBuilder _builder() {
    return StreamBuilder<WinInfoModel>(
      stream: _infoStream?.stream,
      builder: (BuildContext context, AsyncSnapshot<WinInfoModel> snapshot) {
        if (!isLongPress ||
            widget.isLine ||
            !snapshot.hasData ||
            snapshot.data.model == null) return Container(width: 0, height: 0);
        KLineModel model = snapshot.data.model;
        double upDown = model.close - model.open,
            upDownPercent = upDown / model.open * 100;
        List<String> names = ['时间', '开', '高', '低', '收', '涨跌额', '涨幅', '成交量'],
            infos = [
          Date.format(model.id, 'yy-mm-dd hh:nn'),
          Num.fix(model.open),
          Num.fix(model.high),
          Num.fix(model.low),
          Num.fix(model.close),
          '${upDown > 0 ? '+' : ''}${Num.fix(upDown)}',
          '${upDownPercent > 0 ? '+' : ''}${Num.fix(upDownPercent)}%',
          Num.vol(model.vol),
        ];
        return Align(
          alignment:
              snapshot.data.left ? Alignment.topLeft : Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 25),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
                color: ChartColor.markerBgColor,
                border: Border.all(
                    color: ChartColor.markerBorderColor, width: 0.5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(names.length,
                  (i) => _buildItem(infos[i].toString(), names[i])),
            ),
          ),
        );
      },
    );
  }

  Container _buildItem(String info, String name) {
    Color color = Colors.white;
    if (info.startsWith('+'))
      color = Colors.green;
    else if (info.startsWith('-')) color = Colors.red;

    return Container(
      constraints: BoxConstraints(
        minWidth: 95,
        maxWidth: 150,
        maxHeight: 14.0,
        minHeight: 14.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 5),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: ChartStyle.defaultTextSize,
              ),
            ),
          ),
          Text(
            info,
            style: TextStyle(
              color: color,
              fontSize: ChartStyle.defaultTextSize,
            ),
          ),
        ],
      ),
    );
  }
}
