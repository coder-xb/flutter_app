import 'package:flutter/material.dart';
import 'kits/index.dart';

class LoadingToast extends StatelessWidget {
  final String text;
  final Widget loader;
  final TextStyle style;

  LoadingToast({
    Key key,
    this.style,
    this.loader,
    this.text = '数据加载中...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loader ??
            LoaderKit.ring(
              size: 50,
              color: style != null ? style.color : Colors.white,
            ),
        /*ToastLoading.fadeCircle(),*/
        text != null && text.isNotEmpty
            ? Container(
                margin: EdgeInsets.only(top: 16),
                child: Text(text,
                    style: TextStyle(fontSize: 12, color: Colors.white)
                        .merge(style)),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class LoaderKit {
  LoaderKit._();
  static Widget dots({Color color = Colors.white, double size = 50}) =>
      KitDots(color: color, size: size);
  static Widget ring({Color color = Colors.white, double size = 50}) =>
      KitRing(color: color, size: size);
  static Widget inout({Color color = Colors.white, double size = 50}) =>
      KitInout(color: color, size: size);
  static Widget sector({Color color = Colors.white, double size = 50}) =>
      KitSector(color: color, size: size);
  static Widget circle({Color color = Colors.white, double size = 50}) =>
      KitCircle(color: color, size: size);
  static Widget dualRing({Color color = Colors.white, double size = 50}) =>
      KitDualRing(color: color, size: size);
  static Widget fadeCube({Color color = Colors.white, double size = 50}) =>
      KitFadeCube(color: color, size: size);
  static Widget fadeCircle({Color color = Colors.white, double size = 50}) =>
      KitFadeCircle(color: color, size: size);
  static Widget foldCube({Color color = Colors.white, double size = 50}) =>
      KitFoldCube(color: color, size: size);
  static Widget chaseDots({Color color = Colors.white, double size = 50}) =>
      KitChaseDots(color: color, size: size);
  static Widget hourglass({Color color = Colors.white, double size = 50}) =>
      KitHourglass(color: color, size: size);
  static Widget wave({
    Color color = Colors.white,
    double size = 50,
    KitWaveType type = KitWaveType.start,
  }) =>
      KitWave(color: color, size: size, type: type);
}
