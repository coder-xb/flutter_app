import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'widget/index.dart';
import 'core/basis.dart';
import 'core/manager.dart';
import 'core/observer.dart';
import 'core/navigator.dart';
export 'core/basis.dart';
export 'core/navigator.dart';
export 'widget/index.dart' show LoaderKit, ToastPosition;

final GlobalKey<ToastManagerState> _key = GlobalKey<ToastManagerState>();
ToastManagerState get toastManager {
  assert(_key?.currentState != null);
  return _key.currentState;
}

class AppToast {
  static const String _textKey = '_textKey',
      _sheetKey = '_sheetKey',
      _dialogKey = '_dialogKey',
      _loadingKey = '_loadingKey',
      _defaultKey = '_defaultKey',
      _attachedKey = '_attachedKey',
      _notificationKey = '_notificationKey';
  static final Map<String, List<ToastDismiss>> _keys = {
    _textKey: [],
    _sheetKey: [],
    _dialogKey: [],
    _loadingKey: [],
    _defaultKey: [],
    _attachedKey: [],
    _notificationKey: [],
  };

  /// 初始化
  static TransitionBuilder init() {
    ToastBindingObserver();
    return (BuildContext context, Widget child) =>
        ToastManager(key: _key, child: child);
  }

  /// 显示文本Toast
  /// [text] 内容
  /// [radius] Toast圆角半径
  /// [color] Toast背景颜色
  /// [complete] 同[_show.complete]
  /// [backBehavior] 同[_show.backBehavior]
  /// [mainAnimation] 同[showCustom.mainAnimation],默认null
  /// [position] Toast的位置,默认[ToastPosition.center]
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.fadeUp]
  /// [style] 文本样式
  /// [padding] Toast的内边距
  /// [duration] 同[_show.duration]
  /// [animationDuration] 同[showCustom.animationDuration]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  static ToastDismiss showText(
    String text, {
    double radius = 10,
    Color color = Colors.black54,
    VoidCallback complete,
    ToastBackBehavior backBehavior,
    ToastAnimator mainAnimation,
    ToastPosition position = ToastPosition.center,
    ToastAnimator toastAnimation = ToastAnimation.fadeUp,
    TextStyle style = const TextStyle(fontSize: 14, color: Colors.white),
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(15, 5, 15, 7),
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(milliseconds: 300),
    Duration animationReverseDuration,
  }) {
    assert(text != null);
    return showCustom(
      group: _textKey,
      canTap: true,
      cross: true,
      toastTap: true,
      complete: complete,
      onlyOne: true,
      tapDismiss: false,
      enableSafe: true,
      backBehavior: backBehavior,
      duration: duration,
      color: Colors.transparent,
      mainAnimation: mainAnimation,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      builder: (ToastDismiss dismiss) => TextToast(text,
          padding: padding, color: color, radius: radius, style: style),
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        if (toastAnimation != null)
          child = toastAnimation(child, controller, dismiss);
        if (position != null)
          child = Container(
            child: child,
            padding: position.padding,
            alignment: position.alignment,
          );

        return SafeArea(child: child);
      },
    );
  }

  /// 显示加载Toast
  /// [complete] 同[_show.complete]
  /// [backBehavior] 同[_show.backBehavior]
  /// [loader] 加载指示器组件, 默认[LoaderKit.ring]
  /// [text] 附加显示的文本信息
  /// [mainAnimation] 同[showCustom.mainAnimation],默认[ToastAnimation.fade]
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.fade]
  /// [color] MainContent的背景颜色
  /// [iconColor] 图标颜色
  /// [position] Toast的位置,默认[ToastPosition.center]
  /// [duration] 同[_show.duration]
  /// [animationDuration] 同[showCustom.animationDuration]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  /// [style] 附加显示的文本样式
  static ToastDismiss showLoading({
    VoidCallback complete,
    ToastBackBehavior backBehavior,
    Widget loader,
    String text = '数据加载中...',
    ToastAnimator mainAnimation = ToastAnimation.fade,
    ToastAnimator toastAnimation = ToastAnimation.fade,
    Color color = Colors.black54,
    Color iconColor = Colors.white,
    ToastPosition position = ToastPosition.center,
    Duration duration,
    Duration animationDuration = const Duration(milliseconds: 300),
    Duration animationReverseDuration,
    TextStyle style = const TextStyle(fontSize: 12, color: Colors.white),
  }) {
    assert(text != null);
    return showCustom(
      group: _loadingKey,
      cross: true,
      color: color,
      onlyOne: true,
      canTap: false,
      tapDismiss: false,
      toastTap: false,
      builder: (ToastDismiss dismiss) => LoadingToast(
        text: text,
        style: style,
        loader: loader ??
            LoaderKit.ring(
              color: style != null ? style.color : Colors.white,
              size: 50,
            ),
      ),
      backBehavior: backBehavior,
      complete: complete,
      enableSafe: true,
      duration: duration,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      mainAnimation: mainAnimation,
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        if (toastAnimation != null)
          child = toastAnimation(child, controller, dismiss);
        if (position != null)
          child = Container(
            child: child,
            padding: position.padding,
            alignment: position.alignment,
          );
        return SafeArea(child: child);
      },
    );
  }

  /// 关闭Loading, 此方法不会调用[ToastDismiss]
  static void closeLoading() => closeAll(_loadingKey);

  /// 显示通知提示Toast
  /// [title] 标题
  /// [subTitle] 副标题
  /// [style] 标题样式
  /// [subStyle] 副标题样式
  /// [border] ToastContent背景颜色
  /// [color] ToastContent背景颜色,默认[Colors.white]
  /// [radius] ToastContent圆角半径,默认10
  /// [margin] ToastContent外边距,默认10
  /// [prefix] ToastContent前缀组件
  /// [suffix] ToastContent后缀组件
  /// [tapDismiss] 同[_show.tapDismiss]
  /// [toastDimiss] 点击ToastContent能否关闭
  /// [slideDismiss] 能否滑动关闭
  /// [suffixDismiss] 能否点击[suffix]关闭
  /// [onTap] 点击Toast的回调
  /// [complete] 同[_show.complete]
  /// [backBehavior] 同[_show.backBehavior]
  /// [shadow] ToastContent阴影
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.fadeDown]
  /// [padding] ToastContent内边距
  /// [duration] 同[_show.duration]
  /// [animationDuration] 同[showCustom.animationDuration]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  /// [directions] 可滑动关闭的方向
  static ToastDismiss showNotification({
    @required String title,
    String subTitle,
    TextStyle style,
    TextStyle subStyle,
    Border border,
    Color color = Colors.white,
    double radius = 10,
    double margin = 10,
    Widget prefix,
    Widget suffix,
    bool tapDismiss = true,
    bool toastDimiss = false,
    bool slideDismiss = true,
    bool suffixDismiss = true,
    VoidCallback onTap,
    VoidCallback complete,
    ToastBackBehavior backBehavior,
    List<BoxShadow> shadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 10)
    ],
    ToastAnimator toastAnimation = ToastAnimation.fadeDown,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(milliseconds: 300),
    Duration animationReverseDuration,
    List<DismissDirection> directions = const [
      DismissDirection.horizontal,
      DismissDirection.up
    ],
  }) {
    assert(title != null);
    assert(padding != null);
    return showCustom(
      group: _notificationKey,
      cross: true,
      canTap: true,
      onlyOne: true,
      toastTap: false,
      complete: complete,
      backBehavior: backBehavior,
      enableSafe: true,
      duration: duration,
      mainAnimation: null,
      tapDismiss: tapDismiss,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        if (toastAnimation != null)
          child = toastAnimation(child, controller, dismiss);
        return SafeArea(
            child: Align(child: child, alignment: Alignment(0, -.99)));
      },
      builder: (ToastDismiss dismiss) => NotificationToast(
        onTap: onTap,
        title: title,
        style: style,
        color: color,
        radius: radius,
        border: border,
        margin: margin,
        prefix: prefix,
        suffix: suffix,
        shadow: shadow,
        dismiss: dismiss,
        padding: padding,
        subTitle: subTitle,
        subStyle: subStyle,
        directions: directions,
        tapDismiss: toastDimiss,
        slideDismiss: slideDismiss,
        suffixDismiss: suffixDismiss,
      ),
    );
  }

  /// 显示吸附式Toast
  /// [builder] Toast组件构建器
  ///
  /// [target] 以屏幕左上角为原点来计算的目标[Offset]
  /// [context] 目标Widget(如按钮)的[BuildContext],一般会使用[Builder]包裹来获取
  /// 注: [target]和[context]只能二选一,[target]优先级高于[context],若[target]不为null,[context]无效,反之
  ///
  /// [horizontal] 水平偏移,与[direction]有关,根据不同的方向会作用在不用的方向上
  /// [vertical] 垂直偏移,与[direction]有关,根据不同的方向会作用在不用的方向上
  /// [complete] 同[_show.complete]
  /// [canTap] 同[_show.canTap]
  /// [onlyOne] 同[_show.onlyOne]
  /// [safeArea] 此Toast是否显示在app状态栏上,为true则不显示在在app状态栏上,反之
  /// [tapDismiss] 同[_show.tapDismiss]
  /// [toastTap] 同[_show.toastTap]
  /// [enableSafe] 同[_show.enableSafe]
  /// [color] 同[_show.color]
  /// [duration] 同[_show.duration]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  /// [animationDuration] 同[showCustom.animationDuration]
  /// [mainAnimation] 同[showCustom.mainAnimation],默认null
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.fade]
  /// [attached] 吸附方向,在空间允许的情况下,会偏向显示在那边
  static ToastDismiss showAttached({
    @required ToastBuilder builder,
    Offset target,
    BuildContext context,
    double horizontal = 0,
    double vertical = 0,
    VoidCallback complete,
    bool canTap = true,
    bool onlyOne = true,
    bool safeArea = true,
    bool tapDismiss = false,
    bool toastTap = false,
    bool enableSafe = true,
    Color color = Colors.transparent,
    Duration animationReverseDuration,
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(milliseconds: 300),
    ToastAnimator mainAnimation,
    ToastAnimator toastAnimation = ToastAnimation.fade,
    ToastAttached attached = ToastAttached.topCenter,
  }) {
    assert(builder != null);
    assert(vertical != null && vertical >= 0);
    assert(horizontal != null && horizontal >= 0);
    assert(context != null || target != null);
    Rect rect;
    if (target == null) {
      RenderObject render = context.findRenderObject();
      if (render is RenderBox) {
        final Offset offset = render.localToGlobal(Offset.zero);
        rect = Rect.fromLTWH(
            offset.dx, offset.dy, render.size.width, render.size.height);
      } else
        throw Exception(
            'context.findRenderObject() return result must be RenderBox class');
    } else
      rect = Rect.fromLTWH(target.dx, target.dy, 0, 0); // 点矩形

    return showCustom(
      group: _attachedKey,
      cross: false,
      color: color,
      canTap: canTap,
      tapDismiss: true,
      onlyOne: onlyOne,
      complete: complete,
      builder: builder,
      toastTap: toastTap,
      duration: duration,
      enableSafe: enableSafe,
      mainAnimation: mainAnimation,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        return KeyboardVisibility(
          onChange: (bool open) {
            if (open) dismiss();
          },
          child: CustomSingleChildLayout(
            delegate: AttachedLayout(
              target: rect,
              vertical: vertical,
              safeArea: safeArea,
              attached: attached,
              horizontal: horizontal,
            ),
            child: toastAnimation != null
                ? toastAnimation(child, controller, dismiss)
                : child,
          ),
        );
      },
    );
  }

  /// 显示Sheet
  /// [builder] Toast组件构建器
  /// [tapDismiss] 同[_show.tapDismiss]
  /// [complete] 同[_show.complete]
  /// [color] 同[_show.color]
  /// [backBehavior] 同[_show.backBehavior],默认[ToastBackBehavior.close]
  /// [mainAnimation] 同[showCustom.mainAnimation],默认[ToastAnimation.fade]
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.sheet]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  /// [animationDuration] 同[showCustom.animationDuration]
  static ToastDismiss showSheet({
    @required ToastBuilder builder,
    bool tapDismiss = true,
    VoidCallback complete,
    Color color = Colors.black54,
    ToastBackBehavior backBehavior = ToastBackBehavior.close,
    ToastAnimator mainAnimation = ToastAnimation.fade,
    ToastAnimator toastAnimation = ToastAnimation.sheet,
    Duration animationReverseDuration,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    assert(builder != null);
    return showCustom(
      group: _sheetKey,
      cross: false,
      color: color,
      canTap: false,
      onlyOne: true,
      tapDismiss: tapDismiss,
      toastTap: false,
      enableSafe: true,
      complete: complete,
      backBehavior: backBehavior,
      builder: builder,
      mainAnimation: mainAnimation,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        if (toastAnimation != null)
          child = toastAnimation(child, controller, dismiss);
        return Overlay(initialEntries: [
          OverlayEntry(
            builder: (_) => Column(children: [
              Expanded(child: SizedBox.expand()),
              Material(type: MaterialType.transparency, child: child),
            ]),
          )
        ]);
      },
    );
  }

  /// 显示Dialog
  /// [builder] Toast组件构建器
  /// [tapDismiss] 同[_show.tapDismiss]
  /// [complete] 同[_show.complete]
  /// [color] 同[_show.color]
  /// [backBehavior] 同[_show.backBehavior],默认[ToastBackBehavior.close]
  /// [position] Toast的位置,默认[ToastPosition.center]
  /// [mainAnimation] 同[showCustom.mainAnimation],默认[ToastAnimation.fade]
  /// [toastAnimation] 同[showCustom.toastAnimation],默认[ToastAnimation.elastics]
  /// [animationReverseDuration] 同[showCustom.animationReverseDuration]
  /// [animationDuration] 同[showCustom.animationDuration]
  static ToastDismiss showDialog({
    @required ToastBuilder builder,
    bool tapDismiss = true,
    VoidCallback complete,
    Color color = Colors.black54,
    ToastBackBehavior backBehavior = ToastBackBehavior.close,
    ToastPosition position = ToastPosition.center,
    ToastAnimator mainAnimation = ToastAnimation.fade,
    ToastAnimator toastAnimation = ToastAnimation.elastic,
    Duration animationReverseDuration,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    assert(builder != null);
    return showCustom(
      group: _dialogKey,
      cross: false,
      color: color,
      canTap: false,
      onlyOne: true,
      toastTap: false,
      enableSafe: true,
      complete: complete,
      backBehavior: backBehavior,
      builder: builder,
      tapDismiss: tapDismiss,
      mainAnimation: mainAnimation,
      animationDuration: animationDuration,
      animationReverseDuration: animationReverseDuration,
      toastAnimation:
          (Widget child, AnimationController controller, ToastDismiss dismiss) {
        if (toastAnimation != null)
          child = toastAnimation(child, controller, dismiss);
        if (position != null)
          child = Container(
            child: child,
            padding: position.padding,
            alignment: position.alignment,
          );
        return SafeArea(
          child: Overlay(initialEntries: [
            OverlayEntry(
              builder: (_) =>
                  Material(type: MaterialType.transparency, child: child),
            )
          ]),
        );
      },
    );
  }

  /// 显示自定义Toast
  /// [builder] Toast组件构建器
  /// [group] 同[_show.group]
  /// [key] 同[_show.key]
  /// [cross] 同[_show.cross]
  /// [canTap] 同[_show.canTap]
  /// [onlyOne] 同[_show.onlyOne]
  /// [tapDismiss] 同[_show.tapDismiss]
  /// [toastTap] 同[_show.toastTap]
  /// [enableSafe] 同[_show.enableSafe]
  /// [complete] 同[_show.complete]
  /// [backBehavior] 同[_show.backBehavior]
  /// [mainAnimation] 包装MainContent区域的组件,可用于自定义动画(为null则表示不需要动画)或其他一些包裹Widget处理,默认null
  /// [toastAnimation] 包装ToastContent区域的组件,可用于自定义动画(为null则表示不需要动画)或其他一些包裹Widget处理,默认[ToastAnimation.fade]
  /// [color] 同[_show.color]
  /// [duration] 同[_show.duration]
  /// [animationReverseDuration] 反向动画持续时间[AnimationController.reverseDuration]
  /// [animationDuration] 正向动画持续时间[AnimationController.duration],注意不要超过[duration]
  static ToastDismiss showCustom({
    @required ToastBuilder builder,
    String group,
    UniqueKey key,
    bool cross = true,
    bool canTap = true,
    bool onlyOne = true,
    bool tapDismiss = false,
    bool toastTap = false,
    bool enableSafe = true,
    VoidCallback complete,
    ToastBackBehavior backBehavior,
    ToastAnimator mainAnimation,
    ToastAnimator toastAnimation = ToastAnimation.fade,
    Color color = Colors.transparent,
    Duration duration,
    Duration animationReverseDuration,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    assert(builder != null);
    assert(animationDuration != null);
    if (duration != null) assert(duration.compareTo(animationDuration) >= 0);
    AnimationController controller =
        _animationController(animationDuration, animationReverseDuration);

    return _show(
      key: key,
      group: group,
      cross: cross,
      color: color,
      canTap: canTap,
      onlyOne: onlyOne,
      backBehavior: backBehavior,
      complete: complete,
      tapDismiss: tapDismiss,
      toastTap: toastTap,
      duration: duration,
      enableSafe: enableSafe,
      futurer: () => controller?.reverse(),
      builder: (ToastDismiss dismiss) => toastAnimation != null
          ? toastAnimation(builder(dismiss), controller, dismiss)
          : builder(dismiss),
      wrapper: (Widget child, ToastDismiss dismiss) => ToastProxy(
        child: mainAnimation != null
            ? mainAnimation(child, controller, dismiss)
            : child,
        init: () => controller?.forward(),
        dispose: () {
          controller?.dispose();
          controller = null;
        },
      ),
    );
  }

  /// 显示Toast,自带定时关闭,点击屏幕自动关闭,离开当前Route关闭等特性:
  ///   __________________________
  ///  |        MainContent       |
  ///  |                      <------------ canTap
  ///  |                      <------------ tapDismiss
  ///  |    ___________________   |
  ///  |   |                   |  |
  ///  |   |    ToastContent   |  |
  ///  |   |                  <------------ toastTap
  ///  |   |___________________|  |
  ///  |__________________________|
  /// [builder] Toast组件构建器
  /// [group] 此Toast所在分组的标识,主要用于[removeAll]和[remove]
  /// [key] 此Toast的一个标识,凭此可以删除[remove]对应的Toast

  /// [duration] 此Toast持续时间,若为null则不会定时关闭,反之则会按照指定时间自动关闭Toast
  ///
  /// [cross] 跨页面显示
  /// 为true则此Toast会跨越多个Route显示,反之在Route发生变化时会关闭此Toast
  ///
  /// [canTap] 此Toast显示时,能否正常触发当前页面内的点击事件
  /// [onlyOne] 此分组内是否在同时只存在一个Toast,区分是哪一个组是按照[group]来区分的
  /// [tapDismiss] 点击屏幕时是否自动关闭此Toast
  ///
  /// [toastTap] 是否忽视Toast区域的点击事件
  /// 为true时,用户点击Toast区域时可以正常传递到Page上(即事件点透),反之
  ///
  /// [enableSafe] 是否启用安全区,防止键盘挡住Toast
  /// [complete] 在Toast关闭时回调,供外部使用,例如:聚焦到某一个[TextField]
  /// [wrapper] 在此Toast的外层包裹一层,例如:让此Toast的背景层也有动画效果等(Loading)
  /// [futurer] 在Toast关闭之前做一些处理,例如在关闭前调用[AnimationController]来启动并等待动画后再关闭
  ///
  /// [backBehavior] 点击物理返回键的行为
  /// 为null或[ToastBackBehavior.none]不作任何处理
  /// 为[ToastBackBehavior.ignore]拦截返回事件
  /// 为[ToastBackBehavior.close]则关闭此Toast并拦截返回事件
  ///
  /// [color] 此Toast区域MainContent背景颜色

  static ToastDismiss _show({
    @required ToastBuilder builder,
    String group,
    UniqueKey key,
    Duration duration,
    bool cross = true,
    bool canTap = true,
    bool onlyOne = true,
    bool tapDismiss = false,
    bool toastTap = false,
    bool enableSafe = true,
    VoidCallback complete,
    ToastWrapper wrapper,
    ToastFuturer futurer,
    ToastBackBehavior backBehavior,
    Color color = Colors.transparent,
  }) {
    assert(builder != null);
    assert(enableSafe != null);

    /// 由于[cancelHandler]一开始为空的,所以在赋值之前需要在闭包里使用
    ToastDismiss cancelHandler,
        dismissHandler = () async {
          await futurer?.call();
          cancelHandler();
        };

    /// 实现[onlyOne]
    final List<ToastDismiss> caches = (_keys[group ?? _defaultKey] ??= []);
    if (onlyOne) {
      final List<ToastDismiss> copy = caches.toList();
      caches.clear();
      copy.forEach((e) => e());
    }
    caches.add(dismissHandler);

    /// 定时关闭
    Timer timer;
    if (duration != null) {
      timer = Timer(duration, () {
        dismissHandler();
        timer = null;
      });
    }

    /// 跨页(Route改变时)处理
    ToastNavigatorProxy proxy;
    if (!cross) {
      proxy = ToastNavigatorProxy.all(dismissHandler);
      AppToastNavigator.add(proxy);
    }

    /// 拦截点击物理返回按键
    VoidCallback backHandler;
    if (backBehavior == ToastBackBehavior.ignore) {
      backHandler = ToastBindingObserver().add(() => true);
    } else if (backBehavior == ToastBackBehavior.close) {
      backHandler = ToastBindingObserver().add(() {
        dismissHandler();
        backHandler?.call();
        backHandler = null;
        return true;
      });
    }

    cancelHandler = _create(
      key: key,
      group: group,
      builder: (_) {
        return KeyboardSafeArea(
          enable: enableSafe,
          child: ToastProxy(
            dispose: () {
              caches.remove(dismissHandler);
              if (proxy != null) AppToastNavigator.remove(proxy);
              timer?.cancel();
              backHandler?.call();
              SchedulerBinding.instance
                  .addPostFrameCallback((_) => complete?.call());
            },
            child: Builder(builder: (BuildContext context) {
              Widget child = DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2,
                child: Stack(children: [
                  Listener(
                    onPointerDown: tapDismiss ? (_) => dismissHandler() : null,
                    behavior: canTap
                        ? HitTestBehavior.translucent
                        : HitTestBehavior.opaque,
                    child: const SizedBox.expand(),
                  ),
                  IgnorePointer(child: Container(color: color)),
                  IgnorePointer(
                      ignoring: toastTap, child: builder(dismissHandler)),
                ]),
              );
              return wrapper != null ? wrapper(child, dismissHandler) : child;
            }),
          ),
        );
      },
    );

    return dismissHandler;
  }

  /// 创建Toast核心方法(可跨页面)
  /// [builder] Toast组件构建器
  /// [key] 此Toast的一个标识,凭此可以关闭[close]对应的Toast
  /// [group] 此Toast所在分组的标识,主要用于[closeAll]和[close]
  /// [ToastDismiss] 关闭时会调用的方法
  static ToastDismiss _create(
      {@required ToastBuilder builder, UniqueKey key, String group}) {
    assert(builder != null);
    final String gk = group ?? _defaultKey;
    final UniqueKey uk = key ?? UniqueKey();
    final ToastDismiss dismiss = () => close(uk, gk);
    toastManager.add(gk, uk, builder(dismiss));
    return dismiss;
  }

  /// 关闭某个[group]内的对应[key]的Toast
  static void close(UniqueKey key, [String group]) {
    toastManager.close(group ?? _defaultKey, key);
  }

  /// 关闭某个[group]内的所有Toast
  static void closeAll([String group]) {
    toastManager.closeAll(group ?? _defaultKey);
  }

  /// 清空所有的Toast
  static void clean() {
    toastManager.clean();
  }

  /// 初始化[AnimationController]
  static AnimationController _animationController(Duration duration,
      [Duration reverseDuration]) {
    assert(duration != null);
    return AnimationController(
      vsync: ToastTicker(),
      duration: duration,
      reverseDuration: reverseDuration,
    );
  }
}
