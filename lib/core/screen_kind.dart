import 'package:flutter/material.dart';
import 'package:playground/arrowing_ball/arrowing_ball.dart';
import 'package:playground/multi_step_form/multi_step_form.dart';
import 'package:playground/single_step_form/single_step_form.dart';

enum ScreenKind {
  arrowingBall(ArrowingBall(), '引っ張って発射！！'),
  multiStepForm(MultiStepFormScreen(), 'マルチステップフォーム'),
  singleStepForm(SingleStepFormScreen(), 'シングルステップフォーム');

  const ScreenKind(this.widget, this.titleString);
  final Widget widget;
  final String titleString;
}
