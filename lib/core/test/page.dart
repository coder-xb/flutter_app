import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../index.dart';
import '../config/socket.dart';

class KChartPage extends StatefulWidget {
  @override
  _KChartPageState createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> {
  DateTime _date;
  List<KLineModel> _list = List<KLineModel>();
  MainType _mainType = MainType.MA;
  MinorType _minorType = MinorType.MACD;
  bool showLoading = true, isLine = true;
  List<DepthModel> _bids, _asks;
  $WebSocket _webSocket;
  String _curPeriod = '1min', _curSymbol = 'btcusdt';
  List<String> _period = [
        '1min',
        '5min',
        '15min',
        '30min',
        '60min',
        '4hour',
        '1day',
        '1mon',
        '1week',
        '1year',
      ],
      _symbol = ['btcusdt', 'bchusdt', 'eosusdt', 'ethusdt', 'ltcusdt'];

  @override
  void initState() {
    _initData();
    _initDepth();
    super.initState();
  }

  @override
  void dispose() {
    _webSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF17212F),
      body: Column(
        children: <Widget>[
          _appBar(),
          Stack(
            children: <Widget>[
              Container(
                height: 450,
                width: double.infinity,
                child: KChart(
                  _list,
                  isLine: isLine,
                  volType: VolType.VOL,
                  mainType: _mainType,
                  minorType: _minorType,
                ),
              ),
              showLoading
                  ? Container(
                      width: double.infinity,
                      height: 450,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : Container(width: 0, height: 0),
            ],
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buttons(),
                  Container(
                    height: 230,
                    width: double.infinity,
                    child: Depth(_bids, _asks),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _appBar() => MyAppBar(
        color: Colors.transparent,
        prefix: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 22,
          ),
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          disabledColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'KChart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  /// 进来先添加一条数据
  /// 1min之内更新此条数据

  void _getData() {
    _date = DateTime.now();
    _webSocket = $WebSocket(
      'market.$_curSymbol.kline.$_curPeriod',
      callback: (Map<String, dynamic> data) {
        if (data != null) {
          _handlePeriod(KLineModel.fromJson(data['tick']));
          showLoading = false;
          setState(() {});
        }
      },
    );
    Future.delayed(Duration(minutes: 10), () {
      _webSocket?.close();
    });
  }

  void _handlePeriod(KLineModel model) {
    Duration _duration;
    switch (_curPeriod) {
      case '1min':
        _duration = Duration(minutes: 1);
        break;
      case '5min':
        _duration = Duration(minutes: 5);
        break;
      case '15min':
        _duration = Duration(minutes: 15);
        break;
      case '30min':
        _duration = Duration(minutes: 30);
        break;
      case '60min':
        _duration = Duration(minutes: 60);
        break;
      case '4hour':
        _duration = Duration(hours: 4);
        break;
      case '1day':
        _duration = Duration(days: 1);
        break;
      case '1week':
        _duration = Duration(days: 7 - Date.toDatetime().weekday);
        break;
      case '1mon':
        _duration = Duration(days: Date.dayOfMonth() - Date.toDatetime().day);
        break;
      case '1year':
        _duration = Duration(days: Date.dayOfYear() - Date.dayInYear());
        break;
    }
    if (DateTime.now().difference(_date) >= _duration) {
      _date = DateTime.now();
      Data.addLast(_list, model);
    } else
      Data.updateLast(_list, model);
  }

  void _initData([String period = 'day']) {
    showLoading = true;
    Future.delayed(Duration(seconds: 1), () async {
      String _res = await rootBundle.loadString('json/$period.json');
      if (_res != null) {
        List<dynamic> _data = json.decode(_res)['data'];
        _list = _data
            .map((v) => KLineModel.fromJson(v))
            .toList()
            .reversed
            .toList()
            .cast<KLineModel>();
        Data.calculate(_list);
        showLoading = false;
        _getData();
        setState(() {});
      }
    });
  }

  void _initDepth() async {
    String _res = await rootBundle.loadString('json/depth.json');
    if (_res != null) {
      Map<String, dynamic> _data = json.decode(_res)['tick'];
      List<DepthModel> bids = _data['bids']
              .map((v) => DepthModel.fromJson(v))
              .toList()
              .cast<DepthModel>(),
          asks = _data['asks']
              .map((v) => DepthModel.fromJson(v))
              .toList()
              .cast<DepthModel>();
      _depthHandler(bids, asks);
    }
  }

  void _depthHandler(List<DepthModel> bids, List<DepthModel> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = List<DepthModel>();
    _asks = List<DepthModel>();
    double amount = 0;
    bids?.sort((left, right) => left.price.compareTo(right.price));

    /// 倒序循环 / 累加买入委托量
    bids.reversed.forEach((item) {
      amount = Num.add(amount, item.amount);
      item.amount = amount;
      _bids.insert(0, item);
    });

    amount = 0;
    asks?.sort((left, right) => left.price.compareTo(right.price));

    /// 循环 / 累加买入委托量
    asks.forEach((item) {
      amount = Num.add(amount, item.amount);
      item.amount = amount;
      _asks.add(item);
    });
    setState(() {});
  }

  Widget _buttons() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              '时间选择:(当前: ${_curPeriod.toUpperCase()})',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: _period
                .map(
                  (v) => button(v.toUpperCase(), onPressed: () {
                    if (v == '1min') isLine = true;
                    showLoading = true;
                    _curPeriod = v;
                    _initData();
                  }),
                )
                .toList()
                .cast<Widget>(),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              '货币选择:(当前: $_curSymbol)',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: _symbol
                .map(
                  (v) => button(v, onPressed: () {
                    _curSymbol = v;
                    _getData();
                  }),
                )
                .toList()
                .cast<Widget>(),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              '主视图设置:',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              button("分时", onPressed: () => isLine = true),
              button("纯K线", onPressed: () {
                isLine = false;
                _mainType = MainType.NONE;
              }),
              button("MA", onPressed: () {
                isLine = false;
                _mainType = MainType.MA;
              }),
              button("BOLL", onPressed: () {
                isLine = false;
                _mainType = MainType.BOLL;
              }),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              '副视图设置:',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              button("MACD", onPressed: () => _minorType = MinorType.MACD),
              button("KDJ", onPressed: () => _minorType = MinorType.KDJ),
              button("RSI", onPressed: () => _minorType = MinorType.RSI),
              button("WR", onPressed: () => _minorType = MinorType.WR),
              button("隐藏", onPressed: () => _minorType = MinorType.NONE),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              '深度图:',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );

  Widget button(String text, {VoidCallback onPressed}) {
    return FlatButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      child: Text("$text"),
      color: Colors.blue,
    );
  }
}

/*
* class _FormDialog extends StatelessWidget {
  final String text, btn;
  final VoidCallback cancel, confirm, dismiss;

  _FormDialog(
    this.dismiss, {
    Key key,
    this.cancel,
    this.confirm,
    this.text = '',
    this.btn = '确定',
  })  : assert(dismiss != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.center,
      children: [_mainView(), _iconView(), _closeView(), _buttonView()],
    );
  }

  Widget _mainView() => Container(
        width: 295.w,
        height: 240.w,
        margin: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 22.w),
        padding: EdgeInsets.fromLTRB(25.w, 75.w, 25.w, 60.w),
        decoration: BoxDecoration(
          color: AppColor.c_E87841,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text('恭喜您', style: AppText.f32_FFFFFF6),
          Container(
            margin: EdgeInsets.only(top: 10.w),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.f15_FFFFFF,
            ),
          ),
        ]),
      );

  Widget _iconView() => Positioned(
        top: -55.w,
        child: Image.asset(AppFunc.imgApp('icon_success'),
            width: 168, height: 120.w),
      );

  Widget _closeView() => Positioned(
        top: 0,
        right: 0,
        child: Button(
          onTap: _cancelHandler,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.c_E87841,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                width: 2,
                color: AppColor.c_FFFFFF,
              ),
            ),
            child: Icon(AppIcon.close, size: 14, color: AppColor.c_FFFFFF),
          ),
        ),
      );

  Widget _buttonView() => Positioned(
        bottom: 0,
        child: Container(
          width: 155.w,
          height: 44.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.c_FFFFFF,
            borderRadius: BorderRadius.circular(44.w),
          ),
          child: Button(
            onTap: _confirmHandler,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: EdgeInsets.only(left: 6.w),
                child: Text(
                  btn,
                  style: AppText.f17_E878417,
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8.w),
                child: Icon(AppIcon.next, size: 14, color: AppColor.c_E87841),
              )
            ]),
          ),
        ),
      );

  void _cancelHandler() {
    dismiss();
    cancel?.call();
  }

  void _confirmHandler() {
    dismiss();
    confirm?.call();
  }
}
* */
