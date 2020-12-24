import 'dart:async';
import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
part 'adapter/base.dart'; // 适配器基类
part 'adapter/data.dart'; // 数据选择适配器
part 'adapter/time.dart'; // 时间选择适配器
part 'adapter/area.dart'; // 区域选择适配器

typedef PickerConfirm = void Function(Picker picker, List<int> values);
typedef PickerSelect = void Function(
    Picker picker, List<int> values, int index);
typedef PickerCancel = void Function(Picker picker);

class Picker {
  List<int> values; // 当前选定项目的索引

  final bool loop; // 是否可以循环
  final PickerAdapter adapter; // Picker适配器，用于提供数据并生成小部件

  /// 回调函数
  final PickerCancel onCancel;
  final PickerSelect onSelect;
  final PickerConfirm onConfirm;

  final Widget title, // 标题
      cancel, // 取消按钮
      confirm; // 确认按钮

  final divider;

  final String titleText, // 标题文字
      cancelText, // 取消按钮文字
      confirmText; // 确认按钮文字

  final double height, // 选择器高度
      itemExtent; // 选择器栏目子项的高度
  final double space; // 选择器栏目之间的间隙

  final TextStyle style, // 文字样式
      cancelStyle, // 取消按钮文字样式
      confirmStyle, // 确认按钮文字样式
      selectStyle, // 选中项文字样式
      titleStyle; // 标题文字样式

  final Color color, // 选择器背景色
      headColor; // 选择器标题背景色

  Picker({
    this.adapter,
    this.values,
    this.title,
    this.cancel,
    this.confirm,
    this.divider,
    this.onCancel,
    this.onSelect,
    this.onConfirm,
    this.space = 8,
    this.height = 180,
    this.loop = false,
    this.titleText = '',
    this.itemExtent = 36.0,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.color = Colors.white,
    this.headColor = Colors.white,
    this.style = const TextStyle(fontSize: 16, color: Color(0xFF666666)),
    this.titleStyle = const TextStyle(
        fontSize: 16, color: Color(0xFF333333), fontWeight: FontWeight.w600),
    this.cancelStyle = const TextStyle(fontSize: 16, color: Color(0xFF8A8A8A)),
    this.confirmStyle = const TextStyle(fontSize: 16, color: Color(0xFF00B46E)),
    this.selectStyle = const TextStyle(
        fontSize: 16, color: Color(0xFF00B46E), fontWeight: FontWeight.w600),
  }) : assert(adapter != null);

  Widget _widget;
  PickerWidgetState _state;
  Widget get widget => _widget;
  PickerWidgetState get state => _state;
  int _level = 1;

  /// 生成picker控件
  Widget createPicker() {
    _level = adapter.level;
    adapter.picker = this;
    adapter.init();
    _widget = _PickerWidget(picker: this);
    return _widget;
  }

  /// 显示
  Future<T> open<T>(BuildContext context) async =>
      await showModalBottomSheet<T>(
        context: context, //state.context,
        builder: (BuildContext context) => createPicker(),
      );

  /// 获取当前选择的值
  List getValue() => adapter.getValue();

  /// 取消
  void doCancel(BuildContext context) {
    if (onCancel != null) onCancel(this);
    Navigator.of(context).pop<List<int>>();
    _widget = null;
  }

  /// 确定
  void doConfirm(BuildContext context) {
    if (onConfirm != null) onConfirm(this, values);
    Navigator.of(context).pop();
    _widget = null;
  }

  /// 弹制更新指定列的内容，当 onSelect 事件中，修改了当前列前面的列的内容时，可以调用此方法来更新显示
  void update(int index, [bool all = false]) {
    if (all) {
      _state.update();
      return;
    }
    adapter.setCol(index - 1);
    _state._keys[index].currentState.update();
  }
}

/// 数据项
class PickerItem<T> {
  final T value; // 数据值
  final Widget child;
  final List<PickerItem<T>> children; // 子项

  PickerItem({this.value, this.child, this.children});
}

class _PickerWidget<T> extends StatefulWidget {
  final Picker picker;
  _PickerWidget({Key key, @required this.picker}) : super(key: key);

  @override
  PickerWidgetState createState() => PickerWidgetState<T>(picker: this.picker);
}

class PickerWidgetState<T> extends State<_PickerWidget> {
  final Picker picker;
  PickerWidgetState({Key key, @required this.picker});
  final List<FixedExtentScrollController> controller = [];
  final List<GlobalKey<_StateViewState>> _keys = [];

  @override
  void initState() {
    super.initState();
    picker._state = this;
    picker.adapter.show();

    if (controller.length == 0) {
      for (int i = 0; i < picker._level; i++) {
        controller
            .add(FixedExtentScrollController(initialItem: picker.values[i]));
        _keys.add(GlobalKey(debugLabel: i.toString()));
      }
    }
  }

  void update() => setState(() {});

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_head(), _body()],
        ),
      );

  /// 选择器头部
  Widget _head() => Container(
        decoration: BoxDecoration(
          color: picker.headColor,
          border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
          ),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => picker.doCancel(context),
              child: DefaultTextStyle(
                maxLines: 1,
                style: picker.cancelStyle,
                overflow: TextOverflow.ellipsis,
                child: picker.cancel != null
                    ? picker.cancel
                    : Container(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Text(picker.cancelText),
                      ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: DefaultTextStyle(
                  maxLines: 1,
                  style: picker.titleStyle,
                  overflow: TextOverflow.ellipsis,
                  child: picker.title == null
                      ? Text(picker.titleText)
                      : picker.title,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => picker.doConfirm(context),
              child: DefaultTextStyle(
                maxLines: 1,
                style: picker.confirmStyle,
                overflow: TextOverflow.ellipsis,
                child: picker.confirm != null
                    ? picker.confirm
                    : Container(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Text(picker.confirmText),
                      ),
              ),
            ),
          ],
        ),
      );

  Widget _body() => Container(
        height: picker.height,
        color: picker.color,
        padding: EdgeInsets.only(right: picker.space),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _widgets(),
          ),
        ),
      );

  List<Widget> _widgets() {
    List<Widget> _items = <Widget>[];
    PickerAdapter adapter = picker.adapter;
    if (adapter != null) {
      adapter.setCol(-1);
      if (adapter.length > 0) {
        for (int i = 0; i < picker._level; i++) {
          _items.add(Expanded(
            child: Container(
              padding: EdgeInsets.only(left: picker.space),
              child: _StateView(
                key: _keys[i],
                builder: (BuildContext context) {
                  adapter.setCol(i - 1);
                  int _length = adapter.length;
                  return CupertinoPicker.builder(
                    squeeze: 1.5,
                    diameterRatio: 1,
                    backgroundColor: Colors.transparent,
                    itemExtent: picker.itemExtent,
                    scrollController: controller[i],
                    childCount: picker.loop ? null : _length,
                    itemBuilder: (BuildContext context, int index) {
                      adapter.setCol(i - 1);
                      return adapter.build(context, index % _length);
                    },
                    onSelectedItemChanged: (int index) {
                      if (_length <= 0) return;
                      int _index = index % _length;
                      picker.values[i] = _index;
                      updateController(i);
                      adapter.select(i, _index);
                      for (int j = i + 1; j < picker.values.length; j++) {
                        picker.values[j] = 0;
                        controller[j].jumpTo(0);
                      }
                      if (picker.onSelect != null)
                        picker.onSelect(picker, picker.values, i);

                      _keys[i].currentState.update();
                      for (int j = i + 1; j < picker.values.length; j++) {
                        if (j == i) continue;
                        adapter.setCol(j - 1);
                        _keys[j].currentState.update();
                      }
                    },
                  );
                },
              ),
            ),
          ));
          if (picker.divider != null &&
              picker.divider is Widget &&
              i != picker._level - 1) _items.add(picker.divider);
        }
      }
    }
    if (picker.divider != null &&
        picker.divider is List<PickerDivider> &&
        picker.divider.length > 0) {
      for (int i = 0, len = picker.divider.length; i < len; i++) {
        PickerDivider _divider = picker.divider[i];
        if (_divider.child == null) continue;
        Widget _item = Container(child: _divider.child, height: picker.height);
        if (_divider.col >= _items.length)
          _items.add(_item);
        else
          _items.insert(max(0, _divider.col), _item);
      }
    }
    return _items;
  }

  bool _changeing = false;
  void updateController(int i) {
    if (_changeing) return;
    _changeing = true;
    for (int j = 0; j < picker.values.length; j++) {
      if (j != i) {
        if (controller[j].position.maxScrollExtent == null) continue;
        controller[j].position.notifyListeners();
      }
    }
    _changeing = false;
  }
}

class _StateView extends StatefulWidget {
  final WidgetBuilder builder;
  const _StateView({Key key, this.builder}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateViewState();
}

class _StateViewState extends State<_StateView> {
  @override
  Widget build(BuildContext context) => widget.builder(context);

  update() => setState(() {});
}

/// 分隔符
class PickerDivider {
  final int col;
  final Widget child;
  PickerDivider({this.child, this.col = 1}) : assert(child != null);
}
