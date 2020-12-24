import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../../core/basis.dart';
part 'fade.dart';
part 'other.dart';
part 'slide.dart';
part 'bounce.dart';
part 'elastic.dart';

class ToastAnimation {
  ToastAnimation._();
  static const ToastAnimator fade = _Animation.fade;
  static const ToastAnimator fadeUp = _Animation.fadeUp;
  static const ToastAnimator fadeDown = _Animation.fadeDown;
  static const ToastAnimator fadeLeft = _Animation.fadeLeft;
  static const ToastAnimator fadeRight = _Animation.fadeRight;
  static const ToastAnimator flipX = _Animation.flipX;
  static const ToastAnimator flipY = _Animation.flipY;
  static const ToastAnimator bounce = _Animation.bounce;
  static const ToastAnimator bounceUp = _Animation.bounceUp;
  static const ToastAnimator bounceDown = _Animation.bounceDown;
  static const ToastAnimator bounceLeft = _Animation.bounceLeft;
  static const ToastAnimator bounceRight = _Animation.bounceRight;
  static const ToastAnimator elastic = _Animation.elastic;
  static const ToastAnimator elasticUp = _Animation.elasticUp;
  static const ToastAnimator elasticDown = _Animation.elasticDown;
  static const ToastAnimator elasticLeft = _Animation.elasticLeft;
  static const ToastAnimator elasticRight = _Animation.elasticRight;
  static const ToastAnimator slideUp = _Animation.slideUp;
  static const ToastAnimator slideDown = _Animation.slideDown;
  static const ToastAnimator slideLeft = _Animation.slideLeft;
  static const ToastAnimator slideRight = _Animation.slideRight;
  static const ToastAnimator jello = _Animation.jello;
  static const ToastAnimator flash = _Animation.flash;
  static const ToastAnimator pulse = _Animation.pulse;
  static const ToastAnimator swing = _Animation.swing;
  static const ToastAnimator spin = _Animation.spin;
  static const ToastAnimator dance = _Animation.dance;
  static const ToastAnimator zoom = _Animation.zoom;
  static const ToastAnimator sheet = _Animation.sheet;
}

/// ToastAnimation实体类
class _Animation {
  _Animation._();
  static Widget fade(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Fade(child, controller);
  static Widget fadeUp(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      FadeY(child, controller);
  static Widget fadeDown(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      FadeY(child, controller, reverse: true);
  static Widget fadeLeft(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      FadeX(child, controller);
  static Widget fadeRight(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      FadeX(child, controller, reverse: true);
  static Widget flipX(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Flip(child, controller);
  static Widget flipY(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Flip(child, controller, y: true);
  static Widget bounce(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Bounce(child, controller);
  static Widget bounceUp(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      BounceY(child, controller);
  static Widget bounceDown(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      BounceY(child, controller, reverse: true);
  static Widget bounceLeft(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      BounceX(child, controller);
  static Widget bounceRight(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      BounceX(child, controller, reverse: true);
  static Widget elastic(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Elastic(child, controller);
  static Widget elasticUp(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      ElasticY(child, controller);
  static Widget elasticDown(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      ElasticY(child, controller, reverse: true);
  static Widget elasticLeft(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      ElasticX(child, controller);
  static Widget elasticRight(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      ElasticX(child, controller, reverse: true);
  static Widget slideUp(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      SlideY(child, controller);
  static Widget slideDown(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      SlideY(child, controller, reverse: true);
  static Widget slideLeft(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      SlideX(child, controller);
  static Widget slideRight(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      SlideX(child, controller, reverse: true);
  static Widget jello(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Jello(child, controller);
  static Widget flash(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Flash(child, controller);
  static Widget pulse(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Pulse(child, controller);
  static Widget swing(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Swing(child, controller);
  static Widget spin(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Spin(child, controller);
  static Widget dance(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Dance(child, controller);
  static Widget zoom(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Zoom(child, controller);
  static Widget sheet(
          Widget child, AnimationController controller, ToastDismiss dismiss) =>
      Sheet(child, controller);
}
