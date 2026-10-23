import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Yeşil bir bahçede ağaçların etrafında koşuşan yavru kedi ve köpekler.
class PetsAnimation extends StatefulWidget {
  const PetsAnimation({super.key, this.height = 200});
  final double height;
  @override
  State<PetsAnimation> createState() => _PetsAnimationState();
}

class _PetsAnimationState extends State<PetsAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(painter: _GardenPainter(_c.value)),
          ),
        ),
      ),
    );
  }
}

class _Pet {
  const _Pet(this.dog, this.fur, this.light, this.dark);
  final bool dog;
  final Color fur, light, dark;
}

const _orange = _Pet(false, Color(0xFFFF9A3C), Color(0xFFFFE0B8), Color(0xFFB85C14));
const _gray = _Pet(false, Color(0xFF8E9BB8), Color(0xFFE6EAF2), Color(0xFF4F5B78));
const _brown = _Pet(true, Color(0xFFC8843C), Color(0xFFF3D9B1), Color(0xFF6B3E15));
const _cream = _Pet(true, Color(0xFFF7E7CC), Color(0xFFFFFFFF), Color(0xFFB07838));

class _Runner {
  const _Runner(this.tree, this.pet, this.phase, this.dir, this.lap);
  final int tree; // etrafında koştuğu ağaç
  final _Pet pet;
  final double phase; // 0..1 başlangıç
  final double dir; // +1 saat yönü, -1 ters
  final int lap; // 12 sn'deki tur sayısı
}

// Her ağaçta bir kedi bir köpek birbirini kovalar.
const _runners = [
  _Runner(0, _orange, 0.00, 1, 2),
  _Runner(0, _brown, 0.10, 1, 2),
  _Runner(1, _cream, 0.30, -1, 2),
  _Runner(1, _gray, 0.42, -1, 2),
  _Runner(2, _gray, 0.60, 1, 2),
  _Runner(2, _brown, 0.72, 1, 2),
];

class _GardenPainter extends CustomPainter {
  _GardenPainter(this.v);
  final double v; // 0..1 (12 sn)

  static const _treeX = [0.18, 0.5, 0.82];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // gökyüzü
    fill.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3DB5FF), Color(0xFFB8ECFF)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fill);
    fill.shader = null;

    // güneş
    fill.color = const Color(0x55FFE066);
    canvas.drawCircle(Offset(w * 0.86, h * 0.17), h * 0.14, fill);
    fill.color = const Color(0xFFFFD43B);
    canvas.drawCircle(Offset(w * 0.86, h * 0.17), h * 0.085, fill);

    // bulutlar (yavaşça kayar)
    fill.color = Colors.white;
    for (var i = 0; i < 2; i++) {
      final cx = ((i * 0.55 + v) % 1.0) * (w + 140) - 70;
      final cy = h * (0.14 + 0.1 * i);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 56, height: 22), fill);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 16, cy - 8), width: 34, height: 22), fill);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 14, cy - 6), width: 30, height: 20), fill);
    }

    // uzak tepeler
    fill.color = const Color(0xFF2FA84F);
    final hills = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.25, h * 0.46, w * 0.5, h * 0.6)
      ..quadraticBezierTo(w * 0.75, h * 0.72, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hills, fill);

    // çimen zemin
    final gy = h * 0.78; // ağaç diplerinin yeri
    fill.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF58D13F), Color(0xFF2E9E2F)],
    ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.38));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.64, w, h * 0.36), fill);
    fill.shader = null;

    // çimen kılları ve çiçekler (sabit konumlar)
    line.color = const Color(0xFF1F7F28);
    line.strokeWidth = 1.6;
    for (var i = 0; i < 26; i++) {
      final x = w * ((i * 37 % 100) / 100);
      final y = h * (0.68 + 0.3 * ((i * 53 % 100) / 100));
      canvas.drawLine(Offset(x, y), Offset(x - 2, y - 7), line);
      canvas.drawLine(Offset(x, y), Offset(x + 3, y - 6), line);
    }
    const flowerColors = [Color(0xFFFF5C8A), Color(0xFFFFEB3B), Color(0xFFFFFFFF), Color(0xFFFF8A3D)];
    for (var i = 0; i < 14; i++) {
      final x = w * ((i * 61 % 100) / 100);
      final y = h * (0.7 + 0.27 * ((i * 29 % 100) / 100));
      fill.color = flowerColors[i % flowerColors.length];
      canvas.drawCircle(Offset(x, y), 3.2, fill);
      fill.color = const Color(0xFFFFC107);
      canvas.drawCircle(Offset(x, y), 1.2, fill);
    }

    // çalılar
    fill.color = const Color(0xFF1F8A32);
    for (final bx in [0.34, 0.66]) {
      canvas.drawCircle(Offset(w * bx, gy - 4), h * 0.06, fill);
      canvas.drawCircle(Offset(w * bx + h * 0.07, gy - 2), h * 0.05, fill);
      canvas.drawCircle(Offset(w * bx - h * 0.06, gy - 1), h * 0.045, fill);
    }

    // ağacın arkasındakiler
    for (final r in _runners) {
      final st = _state(r, w, h, gy);
      if (!st.front) _drawRunner(canvas, st, r.pet, h);
    }

    // ağaçlar
    for (var t = 0; t < _treeX.length; t++) {
      _drawTree(canvas, Offset(w * _treeX[t], gy), h, t);
    }

    // ağacın önündekiler
    for (final r in _runners) {
      final st = _state(r, w, h, gy);
      if (st.front) _drawRunner(canvas, st, r.pet, h);
    }
  }

  _RunState _state(_Runner r, double w, double h, double gy) {
    final th = 2 * math.pi * (v * r.lap * r.dir + r.phase);
    final cx = w * _treeX[r.tree];
    final rx = w * 0.15, ry = h * 0.075;
    final x = cx + rx * math.cos(th);
    final y = gy + ry * math.sin(th) + h * 0.02;
    final vx = -math.sin(th) * r.dir; // hareket yönü (x)
    final depth = math.sin(th) * 0.5 + 0.5; // 0 arka, 1 ön
    return _RunState(Offset(x, y), vx >= 0, math.sin(th) > 0, 0.85 + 0.25 * depth, v * 12 * 2 * math.pi * 2);
  }

  void _drawTree(Canvas canvas, Offset base, double h, int t) {
    final fill = Paint()..style = PaintingStyle.fill;
    final tw = h * 0.075, th = h * 0.3;
    // gövde
    fill.color = const Color(0xFF8A5528);
    final trunk = RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - tw / 2, base.dy - th, tw, th), Radius.circular(tw * 0.35));
    canvas.drawRRect(trunk, fill);
    fill.color = const Color(0xFF6B3F1A);
    canvas.drawRect(Rect.fromLTWH(base.dx + tw * 0.12, base.dy - th * 0.95, tw * 0.22, th * 0.9), fill);
    // taç (hafif sallanır)
    final sway = math.sin(2 * math.pi * (v * 3 + t * 0.3)) * 2.0;
    final c = Offset(base.dx + sway, base.dy - th - h * 0.06);
    final r = h * 0.17;
    fill.color = const Color(0xFF1E9A33);
    canvas.drawCircle(c.translate(-r * 0.8, r * 0.35), r * 0.85, fill);
    canvas.drawCircle(c.translate(r * 0.8, r * 0.35), r * 0.85, fill);
    fill.color = const Color(0xFF2DBA45);
    canvas.drawCircle(c, r * 1.05, fill);
    fill.color = const Color(0xFF58D96B);
    canvas.drawCircle(c.translate(-r * 0.35, -r * 0.4), r * 0.55, fill);
    // elmalar
    fill.color = const Color(0xFFFF4A4A);
    for (final o in [const Offset(-0.5, 0.1), const Offset(0.4, 0.3), const Offset(0.1, -0.45)]) {
      canvas.drawCircle(c.translate(o.dx * r, o.dy * r), 3.2, fill);
    }
  }

  void _drawRunner(Canvas canvas, _RunState st, _Pet p, double h) {
    final s = h * 0.34 * st.scale;
    final gait = st.gait;
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF3B2A1E);

    // gölge
    fill.color = Colors.black.withAlpha(70);
    canvas.drawOval(Rect.fromCenter(center: st.pos, width: s * 0.8, height: s * 0.13), fill);

    canvas.save();
    canvas.translate(st.pos.dx, st.pos.dy);
    if (!st.right) canvas.scale(-1, 1);

    final bob = -math.sin(gait * 2).abs() * s * 0.05;

    // bacaklar (koşu: çaprazlar birlikte)
    line.strokeWidth = s * 0.085;
    line.color = p.dark;
    const legX = [-0.24, -0.15, 0.16, 0.25];
    const legPh = [0.0, math.pi, math.pi, 0.0];
    for (var i = 0; i < 4; i++) {
      final swing = math.sin(gait + legPh[i]) * s * 0.17;
      final lift = math.max(0.0, math.cos(gait + legPh[i])) * s * 0.05;
      canvas.drawLine(Offset(s * legX[i], -s * 0.2 + bob),
          Offset(s * legX[i] + swing, -lift), line);
    }

    // kuyruk
    final wag = math.sin(gait * 2) * s * 0.05;
    line.color = p.fur;
    line.strokeWidth = s * (p.dog ? 0.09 : 0.075);
    final tailPath = Path()
      ..moveTo(-s * 0.32, -s * 0.3 + bob)
      ..quadraticBezierTo(-s * 0.5, -s * 0.34 + wag, -s * 0.46 + wag,
          -s * (p.dog ? 0.52 : 0.68) + bob);
    canvas.drawPath(tailPath, line);

    // gövde
    final body = Rect.fromCenter(center: Offset(0, -s * 0.29 + bob), width: s * 0.74, height: s * 0.36);
    fill.color = p.fur;
    canvas.drawOval(body, fill);
    canvas.drawOval(body, outline);
    fill.color = p.light;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(s * 0.03, -s * 0.2 + bob), width: s * 0.44, height: s * 0.17),
        fill);

    // kafa
    final hc = Offset(s * 0.34, -s * 0.45 + bob);
    // kulak (kafanın arkasında)
    if (p.dog) {
      fill.color = p.dark;
      canvas.save();
      canvas.translate(hc.dx - s * 0.07, hc.dy - s * 0.1);
      canvas.rotate(0.5 + math.sin(gait * 2) * 0.1);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.07), width: s * 0.11, height: s * 0.22), fill);
      canvas.restore();
    } else {
      final ear = Path()
        ..moveTo(hc.dx - s * 0.12, hc.dy - s * 0.08)
        ..lineTo(hc.dx - s * 0.1, hc.dy - s * 0.3)
        ..lineTo(hc.dx + s * 0.05, hc.dy - s * 0.14)
        ..close();
      fill.color = p.fur;
      canvas.drawPath(ear, fill);
      canvas.drawPath(ear, outline);
      final ear2 = Path()
        ..moveTo(hc.dx + s * 0.02, hc.dy - s * 0.12)
        ..lineTo(hc.dx + s * 0.12, hc.dy - s * 0.3)
        ..lineTo(hc.dx + s * 0.16, hc.dy - s * 0.05)
        ..close();
      canvas.drawPath(ear2, fill);
      canvas.drawPath(ear2, outline);
      fill.color = const Color(0xFFFF9BB5);
      canvas.drawCircle(Offset(hc.dx - s * 0.08, hc.dy - s * 0.17), s * 0.03, fill);
    }
    fill.color = p.fur;
    canvas.drawCircle(hc, s * 0.18, fill);
    canvas.drawCircle(hc, s * 0.18, outline);
    // burun bölgesi
    fill.color = p.light;
    canvas.drawOval(
        Rect.fromCenter(center: hc.translate(s * 0.12, s * 0.06), width: s * 0.17, height: s * 0.12),
        fill);
    // göz
    fill.color = const Color(0xFF1E1620);
    canvas.drawCircle(hc.translate(s * 0.07, -s * 0.03), s * 0.032, fill);
    fill.color = Colors.white;
    canvas.drawCircle(hc.translate(s * 0.06, -s * 0.042), s * 0.011, fill);
    // yanak
    fill.color = const Color(0x66FF6F91);
    canvas.drawCircle(hc.translate(-s * 0.02, s * 0.07), s * 0.04, fill);
    // burun
    fill.color = p.dog ? const Color(0xFF1E1620) : const Color(0xFFFF6F91);
    canvas.drawCircle(hc.translate(s * 0.2, s * 0.03), s * 0.025, fill);
    if (p.dog) {
      fill.color = const Color(0xFFFF5C85); // dışarıdaki dil
      canvas.drawOval(
          Rect.fromCenter(
              center: hc.translate(s * 0.17, s * 0.14 + math.sin(gait * 2).abs() * s * 0.02),
              width: s * 0.06,
              height: s * 0.09),
          fill);
    } else {
      line.color = Colors.white;
      line.strokeWidth = s * 0.01;
      canvas.drawLine(hc.translate(s * 0.17, s * 0.05), hc.translate(s * 0.3, s * 0.02), line);
      canvas.drawLine(hc.translate(s * 0.17, s * 0.07), hc.translate(s * 0.3, s * 0.09), line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GardenPainter old) => old.v != v;
}

class _RunState {
  const _RunState(this.pos, this.right, this.front, this.scale, this.gait);
  final Offset pos;
  final bool right, front;
  final double scale, gait;
}
