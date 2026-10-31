import 'package:flutter/material.dart';

/// Açılış sayfasındaki sevimli yavru kedi fotoğrafı (yumuşak çerçeve, hafif nefes alma hareketi).
class PetsAnimation extends StatefulWidget {
  const PetsAnimation({super.key, this.height = 280});
  final double height;
  @override
  State<PetsAnimation> createState() => _PetsAnimationState();
}

class _PetsAnimationState extends State<PetsAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Center(
      child: Container(
        height: widget.height,
        width: widget.height * 0.78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: accent.withAlpha(110), blurRadius: 36, spreadRadius: 2),
          ],
          border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _c,
                builder: (_, child) => Transform.scale(
                  scale: 1.0 + 0.05 * Curves.easeInOut.transform(_c.value),
                  child: child,
                ),
                child: Image.asset(
                  'assets/images/kedi.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),
              // alt kenarda yumuşak geçiş
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, bg.withAlpha(150)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
