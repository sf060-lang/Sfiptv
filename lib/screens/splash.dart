import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import '../teams.dart';

/// 5 saniyelik açılış ekranı: üstte "SF İPTV PLAYER" (harf harf), altında
/// "Hoşgeldiniz", sonra "Doğayı sev, Hayvanları Koru" ve yürüyen kedi patileri.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const total = 5.0; // saniye
  static const title = 'SF İPTV PLAYER';
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  double _p(double t, double start, double len) => ((t - start) / len).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final team = teamById(context.read<AppState>().team);
    final letters = title.split('');

    return Scaffold(
      backgroundColor: const Color(0xFF05060C),
      body: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final t = c.value; // 0..1
          final secs = t * total;
          final shift = (secs / 2.4) % 1.0;

          final titleRow = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < letters.length; i++)
                _letter(letters[i], _p(t, i * 0.013, 0.14)),
            ],
          );

          final sp = _p(t, 0.26, 0.16);
          final mp = _p(t, 0.38, 0.22);

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.25),
                    radius: 0.95,
                    colors: [
                      Color.alphaBlend(team.pri.withAlpha(107), const Color(0xFF0B0D16)),
                      const Color(0xFF05060C),
                    ],
                  ),
                ),
              ),
              CustomPaint(painter: _RingPainter(secs, team.acc)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) => LinearGradient(
                          colors: [Colors.white, team.acc, Colors.white],
                          tileMode: TileMode.mirror,
                          begin: Alignment(-1 + 2 * shift, 0),
                          end: Alignment(1 + 2 * shift, 0),
                        ).createShader(rect),
                        child: titleRow,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: sp,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - sp)),
                        child: const Text(
                          'Hoşgeldiniz',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 8, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: mp,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '🌿 Doğayı sev, Hayvanları Koru 🐾',
                          style: TextStyle(
                            fontSize: 18,
                            color: team.acc,
                            letterSpacing: 7 - 5.5 * mp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(painter: _PawPainter(secs, team.acc)),
            ],
          );
        },
      ),
    );
  }

  Widget _letter(String ch, double p) {
    final e = Curves.easeOutBack.transform(p);
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, -50 * (1 - e)),
        child: Transform.scale(
          scale: 0.5 + 0.5 * e,
          child: Text(
            ch == ' ' ? ' ' : ch,
            style: const TextStyle(
                fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: 2.5, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Yavaşça genişleyip silinen iki halka.
class _RingPainter extends CustomPainter {
  _RingPainter(this.secs, this.color);
  final double secs;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = math.min(size.width, size.height) * 0.2;
    final center = Offset(size.width / 2, size.height * 0.38);
    for (var k = 0; k < 2; k++) {
      final s = secs - k * 1.2;
      if (s < 0) continue;
      final phase = (s % 3.0) / 3.0;
      final scale = 0.3 + 2.3 * phase;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withAlpha((0.7 * (1 - phase) * 255).round());
      canvas.drawCircle(center, base * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.secs != secs;
}

/// Alt kenarda soldan sağa yürüyen kedi patileri (sağ/sol dönüşümlü, zikzak).
class _PawPainter extends CustomPainter {
  _PawPainter(this.secs, this.color);
  final double secs;
  final Color color;

  static const n = 9;
  static const cycle = 4.8;

  double _alpha(double p) {
    if (p < 0.07) return 0.95 * (p / 0.07);
    if (p < 0.12) return 0.95 - 0.10 * ((p - 0.07) / 0.05);
    if (p < 0.68) return 0.85;
    if (p < 0.88) return 0.85 * (1 - (p - 0.68) / 0.20);
    return 0;
  }

  double _scale(double p) {
    if (p < 0.07) return 0.4 + 0.72 * (p / 0.07);
    if (p < 0.12) return 1.12 - 0.12 * ((p - 0.07) / 0.05);
    return 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sz = (size.width * 0.06).clamp(20.0, 34.0);
    final top = size.height - size.height * 0.07 - 90;
    for (var i = 0; i < n; i++) {
      final s = secs - i * 0.38;
      if (s < 0) continue;
      final p = (s % cycle) / cycle;
      final a = _alpha(p);
      if (a <= 0) continue;
      final x = size.width * (0.05 + i * (0.88 / (n - 1)));
      final y = top + (i.isOdd ? 46.0 : 8.0);
      final rot = (90 + (i.isOdd ? 14 : -14)) * math.pi / 180;

      canvas.save();
      canvas.translate(x + sz / 2, y + sz / 2);
      canvas.rotate(rot);
      final k = sz / 64 * _scale(p);
      canvas.scale(k, k);
      canvas.translate(-32, -32);
      _paw(canvas, Paint()..color = color.withAlpha((a * 255).round()));
      canvas.restore();
    }
  }

  void _toe(Canvas canvas, Paint paint, double cx, double cy, double w, double h, double deg) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(deg * math.pi / 180);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
    canvas.restore();
  }

  void _paw(Canvas canvas, Paint paint) {
    canvas.drawOval(Rect.fromCenter(center: const Offset(32, 43), width: 28, height: 23), paint);
    _toe(canvas, paint, 13, 30, 12, 16, -22);
    _toe(canvas, paint, 25, 17, 12.4, 17.6, 0);
    _toe(canvas, paint, 39, 17, 12.4, 17.6, 0);
    _toe(canvas, paint, 51, 30, 12, 16, 22);
  }

  @override
  bool shouldRepaint(covariant _PawPainter old) => old.secs != secs;
}
