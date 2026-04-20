import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:playground/core/screen_base.dart';

class ArrowingBall extends StatefulWidget {
  const ArrowingBall({super.key});

  @override
  State<ArrowingBall> createState() => _ArrowingBallState();
}

class _ArrowingBallState extends State<ArrowingBall>
    with SingleTickerProviderStateMixin {
  /// 引っ張り開始位置
  Offset _panStartPosition = Offset.zero;

  /// 引っ張り終了位置
  Offset? _panEndOffset;

  /// ボールの位置
  Offset _ballPosition = Offset.zero;

  /// ボールの大きさ
  static const _ballRadius = 30.0;

  /// 画面のAppBarの大きさ
  static const _appBarHeight = 57.0;

  /// 速度の減衰率
  double _damping = 0.99;

  /// 引っ張りに対する初速度の大きさをかける係数
  double _launchScale = 10.0;

  /// ボールが止まったと判定する閾値
  static const _stopThreshold = 10.0;

  /// 速度
  Offset _velocity = Offset.zero;

  /// アニメーションのフレーム管理
  late Ticker _ticker;

  /// 最後のアニメーション時刻
  Duration _lastElapsed = Duration.zero;

  /// ドラッグ中か？
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_isDragging || _velocity.distance < _stopThreshold) return;

    if (_isFirstTick) {
      _lastElapsed = elapsed;
      _isFirstTick = false;
      return;
    }

    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    final size = MediaQuery.sizeOf(context);
    const minX = 0.0;
    final maxX = size.width - _ballRadius;
    const minY = 0.0;
    final maxY = size.height - _appBarHeight - _ballRadius;

    setState(() {
      _velocity *= _damping;
      Offset next = _ballPosition + _velocity * dt;

      // X軸方向の壁衝突判定
      if (next.dx < minX) {
        next = Offset(minX, next.dy);
        _velocity = Offset(-_velocity.dx, _velocity.dy);
      } else if (next.dx > maxX) {
        next = Offset(maxX, next.dy);
        _velocity = Offset(-_velocity.dx, _velocity.dy);
      }

      // Y軸方向の壁衝突判定
      if (next.dy < minY) {
        next = Offset(next.dx, minY);
        _velocity = Offset(_velocity.dx, -_velocity.dy);
      } else if (next.dy > maxY) {
        next = Offset(next.dx, maxY);
        _velocity = Offset(_velocity.dx, -_velocity.dy);
      }

      _ballPosition = next;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeOffset();
  }

  void _initializeOffset() {
    final size = MediaQuery.sizeOf(context);
    setState(() {
      _panStartPosition = Offset(
        (size.width - _ballRadius) / 2,
        (size.height - _ballRadius - _appBarHeight) / 2,
      );
      _ballPosition = _panStartPosition;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _panStartPosition = _calcOffset(details.localPosition);
      _ballPosition = _panStartPosition;
      _velocity = Offset.zero;
      _panEndOffset = null;
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _panEndOffset = _calcOffset(
        details.localPosition,
      ).inverseWith(_panStartPosition);
    });
  }

  bool _isFirstTick = false;

  void _onPanEnd(DragEndDetails details) {
    if (_panEndOffset == null) {
      _isDragging = false;
      return;
    }

    final diff = _panEndOffset! - _panStartPosition;
    _velocity = diff * _launchScale;
    _isFirstTick = true;

    setState(() {
      _ballPosition = _panStartPosition;
      _panEndOffset = null;
      _isDragging = false;
    });
  }

  Offset _calcOffset(Offset localPosition) {
    final size = MediaQuery.sizeOf(context);
    final w = min(
      max(localPosition.dx, _ballRadius / 2),
      size.width - _ballRadius / 2,
    );
    final h = min(
      max(localPosition.dy, _ballRadius / 2),
      size.height - _appBarHeight - _ballRadius / 2,
    );
    return Offset(w - _ballRadius / 2, h - _ballRadius / 2);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 32,
            children: [
              FilledButton.icon(
                onPressed: _initializeOffset,
                label: Text('初期位置ヘリセット'),
                icon: Icon(Icons.restart_alt),
              ),
              Column(
                children: [
                  Text('減衰率: ${_damping.toStringAsFixed(2)} (デフォルト: 0.99)'),
                  Slider(
                    value: _damping,
                    min: 0.9,
                    max: 1.05,
                    divisions: 16,
                    onChanged: (value) {
                      setState(() {
                        _damping = value;
                      });
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text('初速度係数: ${_launchScale.toStringAsFixed(2)} (デフォルト: 10)'),
                  Slider(
                    value: _launchScale,
                    min: 0,
                    max: 50,
                    divisions: 25,
                    onChanged: (value) {
                      setState(() {
                        _launchScale = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Placeholder(
                      color: Colors.blueGrey,
                      strokeWidth: 4,
                      child: SizedBox.expand(
                        child: ColoredBox(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _ballPosition.dx,
                    top: _ballPosition.dy,
                    child: UnconstrainedBox(
                      child: SizedBox(
                        width: _ballRadius,
                        height: _ballRadius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(300),
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _Arrow(
                    initOffset: Offset(
                      _panStartPosition.dx + _ballRadius / 2,
                      _panStartPosition.dy + _ballRadius / 2,
                    ),
                    endOffset: _panEndOffset == null
                        ? null
                        : Offset(
                            _panEndOffset!.dx + _ballRadius / 2,
                            _panEndOffset!.dy + _ballRadius / 2,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.initOffset, required this.endOffset});

  final Offset initOffset;
  final Offset? endOffset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArrowPainter(initOffset: initOffset, endOffset: endOffset),
    );
  }
}

class ArrowPainter extends CustomPainter {
  ArrowPainter({
    super.repaint,
    required this.initOffset,
    required this.endOffset,
  });

  final Offset initOffset;
  final Offset? endOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (endOffset == null) {
      return;
    }

    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(initOffset, endOffset!, p);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ArrowPainter oldDelegate) => false;
}

extension on Offset {
  Offset inverseWith(Offset ground) {
    final dx = ground.dx - this.dx;
    final dy = ground.dy - this.dy;
    return Offset(ground.dx + dx, ground.dy + dy);
  }
}
