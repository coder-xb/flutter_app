part of '../index.dart';

/// 数据选择适配器
class DataAdapter<T> extends PickerAdapter<T> {
  final bool linkage; // 是否联动
  List<PickerItem<T>> data;
  List<PickerItem<dynamic>> _datas;
  int _level = -1, _col = 0;

  DataAdapter({
    List pickers,
    this.data,
    this.linkage = true,
  }) {
    _parseData(pickers);
  }

  @override
  int getLength() => _datas == null ? 0 : _datas.length;

  @override
  int getLevel() {
    if (_level == -1) _checkLevel(data, 1);
    return _level;
  }

  @override
  void init() {
    if (picker.values == null || picker.values.isEmpty) {
      if (picker.values == null) picker.values = <int>[];
      for (int i = 0; i < _level; i++) picker.values.add(0);
    }
  }

  @override
  Widget build(BuildContext context, int index) => createText(
        child: _datas[index].child,
        text: '${_datas[index].value}',
        select: index == picker.values[_col],
      );

  @override
  bool getIsLinkage() => linkage;

  @override
  void setCol(int index) {
    if (_datas != null && _col == index + 1) return;
    _col = index + 1;

    if (linkage) {
      _datas = data;
      if (index >= 0) {
        // 列数过多会有性能问题
        for (int i = 0; i <= index; i++) {
          var _index = picker.values[i];
          if (_datas != null && _datas.length > _index)
            _datas = _datas[_index].children;
          else {
            _datas = null;
            break;
          }
        }
      }
    } else
      _datas = _col < data.length ? data[_col].children : null;
  }

  @override
  List<T> getValue() {
    List<T> _value = <T>[];
    if (picker.values != null && picker.values.isNotEmpty) {
      int _len = picker.values.length;
      if (linkage) {
        List<PickerItem<dynamic>> _temp = data;
        for (int i = 0; i < _len; i++) {
          int _index = picker.values[i];
          if (_index < 0 || _index >= _temp.length) break;
          _value.add(_temp[_index].value);
          _temp = _temp[_index].children;
          if (_temp == null || _temp.isEmpty) break;
        }
      } else {
        for (int i = 0; i < _len; i++) {
          int _index = picker.values[i];
          if (_index < 0 ||
              data[i].children == null ||
              _index >= data[i].children.length) break;
          _value.add(data[i].children[_index].value);
        }
      }
    }
    return _value;
  }

  void _parseData(final List pickers) {
    if (data != null && data.isNotEmpty) return;
    if (pickers != null && pickers.isNotEmpty) {
      if (data == null) data = <PickerItem<T>>[];
      linkage
          ? _parseLinkageDataItem(pickers, data)
          : _parseUnLinkageDataItem(pickers, data);
    }
  }

  /// 处理联动数据
  void _parseLinkageDataItem(List pickers, List<PickerItem> rows) {
    if (pickers == null || pickers.length == 0) return;

    for (int i = 0, len = pickers.length; i < len; i++) {
      var val = pickers[i];

      if (val is T) {
        rows.add(PickerItem<T>(value: val));
      } else if (val is Map) {
        if (val.isEmpty) continue;
        List<T> _keys = val.keys.toList();
        for (int k = 0, _len = _keys.length; k < _len; k++) {
          var _val = val[_keys[k]];
          if (_val is List && _val.isNotEmpty) {
            List<PickerItem> _children = <PickerItem<T>>[];
            rows.add(PickerItem<T>(value: _keys[k], children: _children));
            _parseLinkageDataItem(_val, _children);
          }
        }
      } else if (T == String && !(val is List)) {
        String _val = val.toString();
        rows.add(PickerItem<T>(value: _val as T));
      }
    }
  }

  /// 处理非联动数据
  void _parseUnLinkageDataItem(List pickers, List<PickerItem> rows) {
    if (pickers == null || pickers.length == 0) return;
    for (int i = 0, len = pickers.length; i < len; i++) {
      var val = pickers[i];
      if (!(val is List)) continue;
      List _val = val;
      if (_val.isEmpty) continue;

      PickerItem item = PickerItem<T>(children: <PickerItem<T>>[]);
      rows.add(item);

      for (int j = 0, _len = _val.length; j < _len; j++) {
        var _v = _val[j];
        if (_v is T) {
          item.children.add(PickerItem<T>(value: _v));
        } else if (T == String) {
          String _str = _v.toString();
          item.children.add(PickerItem<T>(value: _str as T));
        }
      }
    }
  }

  /// 遍历层级
  void _checkLevel(List<PickerItem> rows, int index) {
    if (rows == null || rows.length == 0) return;
    if (!linkage) {
      _level = rows.length;
      return;
    }
    for (int i = 0, len = rows.length; i < len; i++) {
      if (rows[i].children != null && rows[i].children.length != 0)
        _checkLevel(rows[i].children, index + 1);
    }
    if (_level < index) _level = index;
  }
}
