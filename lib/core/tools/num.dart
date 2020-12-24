import 'dart:math' as Math;
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';

class Num {
  /// get int by String
  static int toInt(String s) => int.tryParse(s);

  /// get double by String
  static double toDouble(String s) => double.tryParse(s);

  /// 加
  static double add(num a, num b) =>
      (Decimal.parse(a.toString()) + Decimal.parse(b.toString())).toDouble();

  /// 减
  static double sub(num a, num b) =>
      (Decimal.parse(a.toString()) - Decimal.parse(b.toString())).toDouble();

  /// 乘
  static double mul(num a, num b) =>
      (Decimal.parse(a.toString()) * Decimal.parse(b.toString())).toDouble();

  /// 除
  static double div(num a, num b) => b != 0
      ? (Decimal.parse(a.toString()) / Decimal.parse(b.toString())).toDouble()
      : 0;

  /// 求余
  static double rem(num a, num b) => b != 0
      ? (Decimal.parse(a.toString()) % Decimal.parse(b.toString())).toDouble()
      : 0;

  /// 平方根
  static double sqrt(num a) =>
      a.isNegative ? 0 : Math.sqrt(Decimal.parse(a.toString()).toDouble());

  /// 小于
  static bool lt(num a, num b) =>
      Decimal.parse(a.toString()) < Decimal.parse(b.toString());

  /// 大于
  static bool gt(num a, num b) =>
      Decimal.parse(a.toString()) > Decimal.parse(b.toString());

  /// 等于
  static bool eq(num a, num b) =>
      Decimal.parse(a.toString()) == Decimal.parse(b.toString());

  /// 小于等于
  static bool le(num a, num b) =>
      Decimal.parse(a.toString()) <= Decimal.parse(b.toString());

  /// 大于等于
  static bool ge(num a, num b) =>
      Decimal.parse(a.toString()) >= Decimal.parse(b.toString());

  /// 保留小数位数
  static String fix(num a, [int p = 4]) {
    String n = a.toString();
    if (p > 0) {
      if ((n.length - n.lastIndexOf('.') - 1) < p) {
        return a
            .toStringAsFixed(p)
            .substring(0, n.lastIndexOf('.') + p + 1)
            .toString();
      } else
        return n.substring(0, n.lastIndexOf('.') + p + 1).toString();
    } else
      return n.split('.')[0];
  }

  /// 千 => K, 百万 => M
  static String vol(num a, [int p = 4]) {
    if (gt(a, 10000) && lt(a, 999999)) {
      return '${fix(div(a, 1000), p)}K';
    } else if (gt(a, 1000000)) {
      return '${fix(div(a, 1000000), p)}M';
    }
    return fix(a, p);
  }

  /// 小数转换为百分数
  static String per(num a, [int p = 4]) => fix(mul(a, 100), p);

  /// 千分符','转换
  static String ths(num a, [int p = 3]) {
    if (a != null) {
      if (a is int) {
        List<String> v = int.parse(a.toString()).toString().split('');
        for (int i = 0, l = v.length - 1; l >= 0; i++, l--)
          if (i % 3 == 0 && i != 0 && l != 1) v[l] = v[l] + ',';

        return v.join('');
      } else {
        List<String> s = double.parse(a.toString()).toString().split('.'),
            v = s[0].split(''), // 小数点前
            t = s[1].split(''); // 小数点后

        for (int i = 0, l = v.length - 1; l >= 0; i++, l--)
          if (i % 3 == 0 && i != 0 && l != 1) v[l] = v[l] + ',';

        for (int i = 0; i <= p - t.length; i++) t.add('0');

        if (t.length > p) t = t.sublist(0, p);

        return t.length > 0 ? '${v.join('')}.${t.join('')}' : v.join('');
      }
    } else
      return '0';
  }
}

/// 限制输入合法数字
class InpInt extends TextInputFormatter {
  static const def = 0;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldVal,
    TextEditingValue newVal,
  ) {
    String val = newVal.text;
    int index = newVal.selection.end;
    if (val != '' && val != def.toString() && _int(val, def) == def) {
      val = oldVal.text;
      index = oldVal.selection.end;
    }
    return TextEditingValue(
      text: val,
      selection: TextSelection.collapsed(offset: index),
    );
  }

  static int _int(String str, [int val = def]) {
    try {
      return int.parse(str);
    } catch (e) {
      return val;
    }
  }
}

/// 限制输入合法小数
class InpDouble extends TextInputFormatter {
  static const def = 0.01;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldVal,
    TextEditingValue newVal,
  ) {
    String val = newVal.text;
    int index = newVal.selection.end;
    if (val == '.') {
      val = '0.';
      index++;
    } else if (val != '' && val != def.toString() && _float(val, def) == def) {
      val = oldVal.text;
      index = oldVal.selection.end;
    }
    return TextEditingValue(
      text: val,
      selection: TextSelection.collapsed(offset: index),
    );
  }

  static double _float(String str, [double val = def]) {
    try {
      return double.parse(str);
    } catch (e) {
      return val;
    }
  }
}
