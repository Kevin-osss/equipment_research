import 'package:flutter/material.dart';
import 'dart:async';

/*
  这是一个节流函数
 */

typedef ThrottledFunction = void Function();

class Throttle {
  final Duration duration;
  Timer? _timer;
  ThrottledFunction? _function;

  Throttle(this.duration);

  void call(ThrottledFunction function) {
    if (_timer == null) {
      _function = function;
      _timer = Timer(duration, () {
        _timer = null;
        _function?.call();
      });
    }
  }
}
