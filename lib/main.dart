import 'package:flutter/material.dart';
import 'core/test/router.dart';
import 'core/toast/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: AppRouter.generate,
      navigatorObservers: [AppRouter(), AppToastNavigator()],
      builder: AppToast.init(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int num = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppToast示例'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () {
                AppRouter().replace('/second');
              },
              child: Text('第二页'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int num = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('AppToast示例'),
      ),*/
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*RaisedButton(
            onPressed: () {
              // AppData.on<int>('key1').update(++num);
            },
            child: Text('点击+1'),
          ),
            AppData.on<int>('key1', num)
                 .observer((BuildContext context, int val) => Text('$val')),*/

              FlatButton(
                child: Text(
                  "toast风格",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  AppToast.showText("这是默认样式");
                },
              ),
              FlatButton(
                child: Text(
                  "loading风格",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  ToastDismiss dismiss = AppToast.showLoading();
                  Future.delayed(Duration(seconds: 5), () => dismiss());
                },
              ),
              FlatButton(
                child: Text(
                  "notice风格",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  AppToast.showNotification(
                      title: "这是通知样式",
                      suffix: Icon(Icons.close),
                      onTap: () {
                        print('点击关闭');
                      });
                },
              ),
              Builder(builder: (context) {
                return FlatButton(
                  child: Text(
                    "吸附widget在按钮右边",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    //弹出一个定位Toast
                    AppToast.showAttached(
                      context: context,
                      vertical: 10,
                      horizontal: 10,
                      builder: (_) => Container(
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                      ),
                      attached: ToastAttached.rightBottom,
                    );
                  },
                );
              }),
              FlatButton(
                child: Text(
                  "自定义内容",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  AppToast.showCustom(
                    color: Colors.black12,
                    builder: (ToastDismiss dismiss) {
                      return Container(
                        height: 100,
                        width: 100,
                        color: Colors.pink,
                        child: FlatButton(
                          child: Text("关闭"),
                          onPressed: () {
                            dismiss();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              FlatButton(
                child: Text(
                  "BottomSheet",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  AppToast.showSheet(
                    color: Colors.black54,
                    complete: () {
                      print('关闭');
                    },
                    builder: (ToastDismiss dismiss) {
                      return AppSheet(
                        title: '答题领奖励',
                        dismiss: dismiss,
                        child: Container(
                          height: 200,
                          child: Text('123'),
                        ),
                      );
                    },
                  );
                },
              ),
              FlatButton(
                child: Text(
                  "Dialog",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  AppToast.showDialog(
                    color: Colors.black54,
                    complete: () {
                      print('关闭');
                    },
                    builder: (ToastDismiss dismiss) {
                      return AppDialog(
                        title: '答题领奖励',
                        text: 'xxxxx',
                        type: DialogType.success,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSheet extends StatefulWidget {
  final Color color;
  final String title;
  final Widget child;
  final VoidCallback dismiss;

  AppSheet({
    Key key,
    this.dismiss,
    @required this.title,
    @required this.child,
    this.color = Colors.green,
  })  : assert(title != null),
        assert(child != null),
        super(key: key);

  @override
  _AppSheetState createState() => _AppSheetState();
}

class _AppSheetState extends State<AppSheet> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [main(), titleView()]);
  }

  Widget titleView() => Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 32,
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(widget.title),
            ),
            closeBtnView(),
          ],
        ),
      );

  Widget closeBtnView() => GestureDetector(
        onTap: () => widget.dismiss?.call(),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.1))
            ],
          ),
        ),
      );

  Widget main() => Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
            child: widget.child,
          ),
        ),
      );
}

enum DialogType { success, warning, error, question }

class AppDialog extends StatefulWidget {
  final bool close; // 是否可关闭
  final DialogType type;
  final String title, text, btns;
  final VoidCallback cancel, confirm, complete;

  AppDialog({
    Key key,
    this.title,
    this.cancel,
    this.confirm,
    this.complete,
    this.close = true,
    this.btns = '确定',
    @required this.text,
    @required this.type,
  })  : assert(type != null),
        assert(text != null),
        super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<AppDialog> {
  Color color;

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case DialogType.success:
        color = Colors.green;
        break;
      case DialogType.error:
        color = Colors.red;
        break;
      case DialogType.warning:
        color = Colors.orange;
        break;
      case DialogType.question:
        color = Colors.amber;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.close) cancelHandler();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            main(),
            Visibility(visible: widget.close, child: closeBtnView()),
            btnView(),
          ]),
        ],
      ),
    );
  }

  Widget main() => GestureDetector(
        onTap: () => false,
        child: Container(
          width: 295,
          height: 240,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [iconView(), contentView()]),
        ),
      );

  Widget closeBtnView() => Positioned(
        top: 5,
        right: 5,
        child: GestureDetector(
          onTap: cancelHandler,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      );

  Widget iconView() {
    Icon icon;
    switch (widget.type) {
      case DialogType.error:
        icon = Icon(Icons.error, size: 24, color: color);
        break;
      case DialogType.success:
        icon = Icon(Icons.check, size: 24, color: color);
        break;
      case DialogType.warning:
        icon = Icon(Icons.warning, size: 30, color: color);
        break;
      case DialogType.question:
        icon = Icon(Icons.help, size: 30, color: color);
        break;
    }
    return Container(
      width: 80,
      height: 80,
      child: icon,
      margin: EdgeInsets.only(top: 30),
    );
  }

  Widget contentView() => Column(children: [
        widget.title != null && widget.title.isNotEmpty
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Container(height: 20),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]);

  Widget btnView() => Positioned(
        bottom: 0,
        child: GestureDetector(
          onTap: confirmHandler,
          child: Container(
            width: 145,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: Text(
              widget.btns,
            ),
          ),
        ),
      );

  void cancelHandler() {
    Navigator.of(context).pop();
    widget.cancel?.call();
    widget.complete?.call();
  }

  void confirmHandler() {
    Navigator.of(context).pop();
    widget.confirm?.call();
    widget.complete?.call();
  }
}
/*child: Row(children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('标题', style: AppText.f16_3333336),
                    Text(
                      bean.time,
                      style: AppText.f10_999999.copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              bean.status == 0
                  ? '待发货'
                  : bean.status == 1
                      ? '已发货'
                      : '已取消',
              style: bean.status == 0
                  ? AppText.f12_E87841
                  : bean.status == 1
                      ? AppText.f12_00B46E
                      : AppText.f12_999999,
            ),
          ]),*/
