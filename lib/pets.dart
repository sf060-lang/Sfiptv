import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Zıplayan, göz kırpan, kuyruk sallayan sevimli yavru kedi ve köpekler.
class PetsAnimation extends StatefulWidget {
  const PetsAnimation({super.key, this.height = 150});
  final double height;
  @override
  State<PetsAnimation> createState() => _PetsAnimationState();
}

class _PetsAnimationState extends State<PetsAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(painter: _PetsPainter(_c.value)),
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

const _pets = [
  _Pet(false, Color(0xFFFFB46B), Color(0xFFFFE2BF), Color(0xFFE9893A)), // turuncu kedi
  _Pet(true, Color(0xFFD9A066), Color(0xFFF6E3C8), Color(0xFF8A5A2B)), // kahve köpek
  _Pet(false, Color(0xFFBFC7D3), Color(0xFFF1F3F7), Color(0xFF8893A3)), // gri kedi
  _Pet(true, Color(0xFFF4EBDD), Color(0xFFFFFFFF), Color(0xFFA9703C)), // beyaz köpek
];

class _PetsPainter extends CustomPainter {
  _PetsPainter(this.v);
  final double v; // 0..1 döngü

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / _pets.length;
    final s = math.min(slot * 0.95, size.height * 0.9);
    for (var i = 0; i < _pets.length; i++) {
      _drawPet(canvas, _pets[i], Offset(slot * (i + 0.5), size.height - 6), s, i);
    }
  }

  void _drawPet(Canvas canvas, _Pet p, Offset base, double s, int i) {
    final ph = i * 0.25;
    final jump = math.max(0.0, math.sin(2 * math.pi * (v + ph))) * s * 0.16; // zıplama
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // gölge
    fill.color = Colors.black.withAlpha(60);
    canvas.drawOval(
        Rect.fromCenter(center: base, width: s * (0.7 - jump / s * 0.6), height: s * 0.1), fill);

    final bodyC = base.translate(0, -s * 0.2 - jump * 0.6);
    final headC = base.translate(0, -s * 0.55 - jump);

    // kuyruk
    final wag = math.sin(2 * math.pi * (v * 2 + ph)) * 0.5;
    line.color = p.fur;
    line.strokeWidth = s * (p.dog ? 0.09 : 0.075);
    final tailBase = bodyC.translate(s * 0.28, s * 0.02);
    final tail = Path()
      ..moveTo(tailBase.dx, tailBase.dy)
      ..quadraticBezierTo(tailBase.dx + s * 0.22, tailBase.dy - s * 0.05 + wag * s * 0.1,
          tailBase.dx + s * 0.2 + wag * s * 0.12, tailBase.dy - s * (p.dog ? 0.22 : 0.34));
    canvas.drawPath(tail, line);

    // gövde
    fill.color = p.fur;
    canvas.drawOval(
        Rect.fromCenter(center: bodyC, width: s * 0.66, height: s * 0.46), fill);
    fill.color = p.light;
    canvas.drawOval(
        Rect.fromCenter(center: bodyC.translate(0, s * 0.04), width: s * 0.36, height: s * 0.3),
        fill);
    // patiler
    fill.color = p.light;
    for (final dx in [-0.17, 0.17]) {
      canvas.drawOval(
          Rect.fromCenter(center: base.translate(s * dx, -s * 0.03 - jump * 0.2),
              width: s * 0.17, height: s * 0.1),
          fill);
    }

    // kulaklar
    if (p.dog) {
      final sway = math.sin(2 * math.pi * (v * 2 + ph)) * 0.08;
      fill.color = p.dark;
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(headC.dx + side * s * 0.27, headC.dy - s * 0.18);
        canvas.rotate(side * (0.35 + sway));
        canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.08), width: s * 0.17, height: s * 0.3), fill);
        canvas.restore();
      }
    } else {
      for (final side in [-1.0, 1.0]) {
        final tip = headC.translate(side * s * 0.25, -s * 0.38);
        final outer = Path()
          ..moveTo(headC.dx + side * s * 0.1, headC.dy - s * 0.27)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(headC.dx + side * s * 0.33, headC.dy - s * 0.08)
          ..close();
        fill.color = p.fur;
        canvas.drawPath(outer, fill);
        final inner = Path()
          ..moveTo(headC.dx + side * s * 0.14, headC.dy - s * 0.24)
          ..lineTo(tip.dx - side * s * 0.01, tip.dy + s * 0.06)
          ..lineTo(headC.dx + side * s * 0.28, headC.dy - s * 0.1)
          ..close();
        fill.color = const Color(0xFFFFA9C0);
        canvas.drawPath(inner, fill);
      }
    }

    // kafa
    fill.color = p.fur;
    canvas.drawCircle(headC, s * 0.3, fill);
    fill.color = p.light;
    canvas.drawOval(
        Rect.fromCenter(center: headC.translate(0, s * 0.1), width: s * 0.3, height: s * 0.2),
        fill);
    if (p.dog) {
      // göz çevresi lekesi
      fill.color = p.dark.withAlpha(150);
      canvas.drawCircle(headC.translate(-s * 0.12, -s * 0.03), s * 0.085, fill);
    }

    // yanaklar
    fill.color = const Color(0xFFFF8FA8).withAlpha(110);
    for (final side in [-1.0, 1.0]) {
      canvas.drawCircle(headC.translate(side * s * 0.2, s * 0.08), s * 0.05, fill);
    }

    // gözler (göz kırpma)
    final blink = ((v * 2 + ph * 1.7) % 1.0) > 0.93;
    for (final side in [-1.0, 1.0]) {
      final ec = headC.translate(side * s * 0.12, -s * 0.03);
      if (blink) {
        line.color = const Color(0xFF2A2230);
        line.strokeWidth = s * 0.025;
        canvas.drawLine(ec.translate(-s * 0.045, 0), ec.translate(s * 0.045, 0), line);
      } else {
        fill.color = const Color(0xFF2A2230);
        canvas.drawCircle(ec, s * 0.052, fill);
        fill.color = Colors.white;
        canvas.drawCircle(ec.translate(-s * 0.015, -s * 0.018), s * 0.018, fill);
      }
    }

    // burun + ağız
    fill.color = p.dog ? const Color(0xFF2A2230) : const Color(0xFFFF7FA0);
    final nc = headC.translate(0, s * 0.07);
    canvas.drawOval(Rect.fromCenter(center: nc, width: s * 0.075, height: s * 0.05), fill);
    line.color = const Color(0xFF2A2230);
    line.strokeWidth = s * 0.016;
    final mouth = Path()
      ..moveTo(nc.dx, nc.dy + s * 0.025)
      ..quadraticBezierTo(nc.dx - s * 0.04, nc.dy + s * 0.085, nc.dx - s * 0.08, nc.dy + s * 0.045)
      ..moveTo(nc.dx, nc.dy + s * 0.025)
      ..quadraticBezierTo(nc.dx + s * 0.04, nc.dy + s * 0.085, nc.dx + s * 0.08, nc.dy + s * 0.045);
    canvas.drawPath(mouth, line);
    if (p.dog) {
      // sallanan dil
      final tl = (math.sin(2 * math.pi * (v * 2 + ph)) * 0.5 + 0.5) * s * 0.03;
      fill.color = const Color(0xFFFF6F91);
      canvas.drawOval(
          Rect.fromCenter(
              center: nc.translate(0, s * 0.1 + tl / 2), width: s * 0.06, height: s * 0.07 + tl),
          fill);
    } else {
      // bıyıklar
      line.color = Colors.white.withAlpha(220);
      line.strokeWidth = s * 0.012;
      for (final side in [-1.0, 1.0]) {
        for (final dy in [-0.01, 0.03]) {
          canvas.drawLine(nc.translate(side * s * 0.1, s * dy),
              nc.translate(side * s * 0.25, s * (dy - 0.02)), line);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PetsPainter old) => old.v != v;
}
