class Date {
  static String format([var time, String fmt]) {
    fmt = (fmt != null && fmt.isNotEmpty) ? fmt : 'yyyy-mm-dd hh:nn:ss';
    DateTime tm = toDatetime(time);
    Map<String, int> obj = {
      'm+': tm.month, // 月
      'd+': tm.day, // 日
      'h+': tm.hour, // 时(24小时制)
      'H+': (tm.hour % 12 == 0) ? 12 : tm.hour % 12, // 时(12小时制)
      'n+': tm.minute, // 分
      's+': tm.second, // 秒
      'S+': tm.millisecondsSinceEpoch, // 毫秒
      'u+': tm.microsecondsSinceEpoch, // 微秒
    };

    /// 年
    Iterable<RegExpMatch> year = RegExp(r'(y+)').allMatches(fmt);
    if (year.length != 0) {
      String sy = year.first.group(0), stmy = tm.year.toString();
      fmt = fmt.replaceAll(sy, stmy.substring(4 - sy.length));
    }

    /// 月
    Iterable<RegExpMatch> month = RegExp(r'(M+)').allMatches(fmt);
    if (month.length != 0) {
      String sm = month.first.group(0);
      fmt = fmt.replaceAll(
          sm, sm.length == 1 ? _mShort[tm.month - 1] : _mLong[tm.month - 1]);
    }

    /// 每月的第n周
    Iterable<RegExpMatch> weekInMonth = RegExp(r'(w+)').allMatches(fmt);
    if (weekInMonth.length != 0) {
      String wkm = weekInMonth.first.group(0), sd = '${(tm.day + 7) ~/ 7}';
      fmt = fmt.replaceAll(
          wkm, wkm.length == 1 ? sd : '00$sd'.substring(sd.length));
    }

    /// 每年的第n周
    Iterable<RegExpMatch> weekInYear = RegExp(r'(W+)').allMatches(fmt);
    if (weekInYear.length != 0) {
      String wky = weekInYear.first.group(0),
          sd = '${(dayInYear(tm) + 7) ~/ 7}';
      fmt = fmt.replaceAll(
          wky, wky.length == 1 ? sd : '00$sd'.substring(sd.length));
    }

    /// 周n
    Iterable<RegExpMatch> weekday = RegExp(r'(D+)').allMatches(fmt);
    if (weekday.length != 0) {
      String sw = weekday.first.group(0);
      fmt = fmt.replaceAll(sw,
          sw.length == 1 ? _wShort[tm.weekday - 1] : _wLong[tm.weekday - 1]);
    }

    /// 上下午
    Iterable<RegExpMatch> ap = RegExp(r'(ap)').allMatches(fmt);
    if (ap.length != 0)
      fmt = fmt.replaceAll(ap.first.group(0), tm.hour < 12 ? 'AM' : 'PM');

    /// 时区z
    Iterable<RegExpMatch> sz = RegExp(r'(z)').allMatches(fmt);
    if (sz.length != 0) {
      String strz = sz.first.group(0);
      if (tm.timeZoneOffset.inMinutes == 0) {
        fmt = fmt.replaceAll(strz, 'Z');
      } else {
        if (tm.timeZoneOffset.isNegative) {
          String _hs = '${-tm.timeZoneOffset.inHours % 24}'.padLeft(2, '0'),
              _ms = '${-tm.timeZoneOffset.inMinutes % 60}'.padLeft(2, '0');
          fmt = fmt.replaceAll(strz, '-$_hs$_ms');
        } else {
          String _hs = '${tm.timeZoneOffset.inHours % 24}'.padLeft(2, '0'),
              _ms = '${tm.timeZoneOffset.inMinutes % 60}'.padLeft(2, '0');
          fmt = fmt.replaceAll(strz, '+$_hs$_ms');
        }
      }
    }

    /// 时区Z
    Iterable<RegExpMatch> tz = RegExp(r'(Z)').allMatches(fmt);
    if (tz.length != 0)
      fmt = fmt.replaceAll(tz.first.group(0), tm.timeZoneName);

    /// 其他部分
    obj.forEach((k, v) {
      Iterable<RegExpMatch> reg = RegExp(r'(' + k + ')').allMatches(fmt);
      if (reg.length != 0) {
        String sm = reg.first.group(0), sv = v.toString();
        fmt = fmt.replaceAll(
            sm,
            sm.length == 1
                ? sv
                : ((k == 'S+' || k == 'u+') ? '000$sv' : '00$sv')
                    .substring(sv.length));
      }
    });
    return fmt;
  }

  /// 根据时间戳(或DateTime)计算当年的第n天
  static int dayInYear([var time]) {
    DateTime tm = toDatetime(time);
    return tm.difference(DateTime(tm.year, 1, 1)).inDays;
  }

  /// 根据时间戳(或DateTime)获取某月的天数
  static int dayOfMonth([var time]) {
    DateTime tm = toDatetime(time);
    if (tm.month == 2) {
      int y = tm.year;
      return y % 4 == 0 && y % 100 != 0 || y % 400 == 0 ? 29 : 28;
    } else
      return _ms[tm.month - 1];
  }

  /// 根据时间戳(或DateTime)获取某年的天数
  static int dayOfYear([var time]) {
    int y = toDatetime(time).year;
    return y % 4 == 0 && y % 100 != 0 || y % 400 == 0 ? 366 : 365;
  }

  /// 转换为DateTime
  static DateTime toDatetime([var time]) {
    if (time == null) return DateTime.now();
    if (time is DateTime) return time;
    time = (time is int && time != 0)
        ? (time.toString().length != 10 ? time : time * 1000)
        : DateTime.now().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// 转换为Timestap
  static int toTimestap([var time]) => toDatetime(time).millisecondsSinceEpoch;

  static List<String> _mShort = const <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  static List<int> _ms = const <int>[
    31, // 1
    0, // 2
    31, // 3
    30, // 4
    31, // 5
    30, // 6
    31, // 7
    31, // 8
    30, // 9
    31, // 10
    30, // 11
    31, // 12
  ];

  static List<String> _mLong = const <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static List<String> _wShort = const <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thur',
    'Fri',
    'Sat',
    'Sun'
  ];
  static List<String> _wLong = const <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
}
