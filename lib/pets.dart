import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import 'i18n.dart';

/// Açılış sayfası: uygulama ikonu uzaktan küçük başlayıp öne doğru gelirken büyür,
/// ardından hafifçe nefes alır; arkasında kırmızı/mavi halkalar yayılır.
class PetsAnimation extends StatefulWidget {
  const PetsAnimation({super.key});
  @override
  State<PetsAnimation> createState() => _PetsAnimationState();
}

class _PetsAnimationState extends State<PetsAnimation> with TickerProviderStateMixin {
  late final AnimationController _in =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final h = (mq.size.height * 0.46).clamp(280.0, 480.0);
    final iconSize = math.min(h * 0.62, mq.size.width * 0.62).clamp(150.0, 340.0);
    return SizedBox(
      width: double.infinity,
      height: h,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // koyu mavi zemin
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF14307A), const Color(0xFF0A1B4D), bg],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_in, _loop]),
              builder: (_, __) {
                final a = Curves.easeOutCubic.transform(_in.value);
                final scale = 0.04 + 0.96 * a; // uzaktan öne
                final breathe = 1 + 0.03 * math.sin(2 * math.pi * _loop.value) * _in.value;
                final opacity = (_in.value * 3).clamp(0.0, 1.0);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _RingsPainter(_loop.value, _in.value, iconSize),
                    ),
                    Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale * breathe,
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(iconSize * 0.22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53945).withAlpha((120 * a).round()),
                                blurRadius: 40 * a + 1,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/icon.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Text(
                'SF İPTV Player',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const [Shadow(blurRadius: 14, color: Colors.black87)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.t, this.appear, this.iconSize);
  final double t, appear, iconSize;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 2; i++) {
      final p = (t + i * 0.5) % 1.0;
      final r = iconSize * (0.55 + 0.75 * p);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = (i == 0 ? const Color(0xFFE53945) : const Color(0xFF4D7CFF))
            .withAlpha((110 * (1 - p) * appear).round());
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.t != t || old.appear != appear;
}
