part of '../index.dart';

/// 选择器适配器
abstract class PickerAdapter<T> {
  Picker picker;

  /// 初始化
  void init();

  /// 获取长度
  int getLength();
  int get length => getLength();

  /// 获取最大层级
  int getLevel();
  int get level => getLevel();

  /// 设置列表栏目
  void setCol(int index);

  /// 显示
  void show() {}

  /// 选择
  void select(int col, int index) {}

  /// 获取文字
  String getText() => getValue().toString();
  String get text => getText();

  /// 获取选中的值
  List<T> getValue() => [];

  /// 是否联动，即后面的列受前面列数据影响
  bool getIsLinkage() => true;
  bool get isLinkage => getIsLinkage();

  /// 创建Text组件
  Widget createText({
    String text,
    Widget child,
    bool select = false,
  }) =>
      Center(
        child: DefaultTextStyle(
          maxLines: 1,
          style: picker.style,
          overflow: TextOverflow.ellipsis,
          child: child == null
              ? Text(text, style: select ? picker.selectStyle : null)
              : child,
        ),
      );

  /// 创建
  Widget build(BuildContext context, int index);

  /// 通知适配器数据改变
  void notify() {
    if (picker != null && picker.state != null) {
      picker.adapter.show();
      picker.adapter.init();
      for (int i = 0, len = picker.values.length; i < len; i++)
        picker.state.controller[i].jumpToItem(picker.values[i]);
    }
  }

  @override
  String toString() => text;
}
