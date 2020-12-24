part of '../index.dart';

class DateTimeAdapter extends PickerAdapter<DateTime> {
  final int type, // 展示类型
      minYear, // 选择最小年份
      maxYear, // 选择最大年份
      minHour, // 选择最小小时
      maxHour, // 选择最大小时
      minuteInterval; // 分钟间隔，可以选择30分钟，5分钟等间隔的时间。
  final String unitYear, unitMonth, unitDay; // 年月日后缀

  DateTime value; // 当前初始时间
  final DateTime minValue, maxValue; // 时间区间

  int _col = 0, _minYear = 0, _maxYear = 0, _minHour = 0, _maxHour = 0;

  DateTimeAdapter({
    Picker picker,
    this.type = DateTimeType.HMS,
    this.minYear = 1900,
    this.maxYear = 2100,
    this.value,
    this.minValue,
    this.maxValue,
    this.minHour = 0,
    this.maxHour = 23,
    this.unitYear,
    this.unitMonth,
    this.unitDay,
    this.minuteInterval,
  })  : assert(minYear >= 0),
        assert(maxYear >= 0),
        assert(minYear <= maxYear),
        assert(minHour >= 0 && minHour < 24),
        assert(maxHour >= 0 && maxHour < 24),
        assert(minHour < maxHour),
        assert(minuteInterval == null ||
            (minuteInterval >= 1 &&
                minuteInterval <= 30 &&
                (60 % minuteInterval == 0))) {
    super.picker = picker;
    _calcInit();
  }

  @override
  void init() {
    if (picker.values == null || picker.values.isEmpty) {
      if (picker.values == null) picker.values = <int>[];
      for (int i = 0; i < level; i++) picker.values.add(0);
    }
  }

  @override
  int getLength() {
    int val = _lengths[type][_col];
    // 年
    if (val == 0) {
      int year = _maxYear;
      if (maxValue != null) year = maxValue.year;
      return year - _minYear + 1;
    }
    // 日
    if (val == 31) return _calcMonDays(value.year, value.month);

    switch (getColType(_col)) {
      case 3: // 时
        return _maxHour - _minHour + 1;
        break;
      case 4: // 分
        if (minuteInterval != null && minuteInterval > 1)
          return val ~/ minuteInterval;
        break;
    }
    return val;
  }

  @override
  int getLevel() => _lengths[type].length;

  @override
  void setCol(int index) {
    _col = index + 1;
    if (_col < 0) _col = 0;
  }

  @override
  Widget build(BuildContext context, int index) {
    String _text = '';
    switch (getColType(_col)) {
      case 0: // 年
        _text = '${_minYear + index}${_checkStr(unitYear) ? unitYear : ''}';
        break;
      case 1: // 月
        _text = _checkStr(unitMonth)
            ? '${index + 1}$unitMonth'
            : '${index + 1}'.padLeft(2, '0');
        break;
      case 2: // 日
        _text = _checkStr(unitDay)
            ? '${index + 1}$unitDay'
            : '${index + 1}'.padLeft(2, '0');
        break;
      case 3: // 时
        _text = '${index + _minHour}'.padLeft(2, '0');
        break;
      case 4: // 分
        _text = (minuteInterval == null || minuteInterval < 2)
            ? '$index'.padLeft(2, '0')
            : '${index * minuteInterval}'.padLeft(2, '0');
        break;
      case 5: // 秒
        _text = '$index'.padLeft(2, '0');
        break;
    }

    return createText(text: _text, select: index == picker.values[_col]);
  }

  @override
  String getText() => value.toString();

  @override
  void show() {
    if (_minYear == 0) getLength();
    for (int i = 0; i < level; i++) {
      switch (getColType(i)) {
        case 0: // 年
          picker.values[i] = value.year - _minYear;
          break;
        case 1: // 月
          picker.values[i] = value.month - 1;
          break;
        case 2: // 日
          picker.values[i] = value.day - 1;
          break;
        case 3: // 时
          picker.values[i] = value.hour;
          break;
        case 4: // 分
          picker.values[i] = minuteInterval == null || minuteInterval < 2
              ? value.minute
              : value.minute ~/ minuteInterval;
          break;
        case 5: // 秒
          picker.values[i] = value.second;
          break;
      }
    }
  }

  @override
  void select(int col, int index) {
    int year = value.year,
        month = value.month,
        day = value.day,
        h = value.hour,
        m = value.minute,
        s = value.second;
    if (type != DateTimeType.HMS && type != DateTimeType.YMDHMS) s = 0;
    switch (getColType(col)) {
      case 0: // 年
        year = _minYear + index;
        break;
      case 1: // 月
        month = index + 1;
        break;
      case 2: // 日
        day = index + 1;
        break;
      case 3: // 时
        h = index + _minHour;
        break;
      case 4: // 分
        m = (minuteInterval == null || minuteInterval < 2)
            ? index
            : index * minuteInterval;
        break;
      case 5: // 秒
        s = index;
        break;
    }
    day = _calcMonDays(year, month);
    value = DateTime(year, month, day, h, m, s);
  }

  /// 计算初始数据
  void _calcInit() {
    _minYear = minYear;
    _maxYear = maxYear;
    _minHour = minHour;
    _maxHour = maxHour;
    DateTime _now = DateTime.now();
    if (minValue != null) {
      _minYear = max(minValue.year, _minYear);
      if (value != null) assert(minValue.isAfter(value));
      if (maxValue != null) {
        if (value != null)
          assert(maxValue.isAfter(value));
        else
          assert(maxValue.isAfter(minValue));
      }
    }
    if (maxValue != null) {
      _maxYear = min(maxValue.year, _maxYear);
      if (value != null) assert(maxValue.isBefore(value));
      if (minValue != null) {
        if (value != null)
          assert(minValue.isBefore(value));
        else
          assert(minValue.isBefore(maxValue));
      }
    }

    if (value == null) {
      if (_minYear < _now.year) {
        value = _maxYear < _now.year
            ? DateTime(_maxYear, _now.month, _now.day, _now.hour, _now.minute,
                _now.second)
            : _now;
      } else
        value = DateTime(_minYear, _now.month, _now.day, _now.hour, _now.minute,
            _now.second);
    }
  }

  /// 获取当前列的类型
  int getColType(int index) {
    List<int> items = _coltype[type];
    if (index >= items.length) return -1;
    return items[index];
  }

  /// 计算时间总数
  int _calcMonDays(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
        break;
      case 2:
        if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) return 29;
        return 28;
        break;
    }
    return 30;
  }

  bool _checkStr(String val) => val != null && val.isNotEmpty;

  /// 可以提高性能
  List<List<int>> _lengths = const [
    [0], // y
    [0, 12], // y, m
    [0, 12, 31], // y, m, d
    [0, 12, 31, 24], // y, m, d, hh
    [0, 12, 31, 24, 60], // y, m, d, hh, mm
    [0, 12, 31, 24, 60, 60], // y, m, d, hh, mm, ss
    [24], // hh
    [24, 60], // hh, mm
    [24, 60, 60], // hh, mm, ss
  ];

  /// 0-year，1-month，2-day，3-hour，4-minute，5-second
  List<List<int>> _coltype = const [
    [0], // y
    [0, 1], // y, m
    [0, 1, 2], // y, m, d
    [0, 1, 2, 3], // y, m, d, hh
    [0, 1, 2, 3, 4], // y, m, d, hh, mm
    [0, 1, 2, 3, 4, 5], // y, m, d, hh, mm, ss
    [3], // hh
    [3, 4], // hh, mm
    [3, 4, 5], // hh, mm, ss
  ];
}

class DateTimeType {
  static const int Y = 0; // y
  static const int YM = 1; // y, m
  static const int YMD = 2; // y, m, d
  static const int YMDH = 3; // y, m, d, hh
  static const int YMDHM = 4; // y, m, d, hh, mm
  static const int YMDHMS = 5; // y, m, d, hh, mm, ss
  static const int H = 6; // hh
  static const int HM = 7; // hh, mm
  static const int HMS = 8; // hh, mm, ss
}
