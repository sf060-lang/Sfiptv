import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';

/// Açılış sayfasında üst ekranı tamamen kaplayan sevimli yavru kedi fotoğrafı
/// (uçtan uca, hafif nefes alma hareketi, altta yumuşak geçiş ve uygulama adı).
class PetsAnimation extends StatefulWidget {
  const PetsAnimation({super.key});
  @override
  State<PetsAnimation> createState() => _PetsAnimationState();
}

class _PetsAnimationState extends State<PetsAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final h = (mq.size.height * 0.5).clamp(260.0, 520.0);
    return SizedBox(
      width: double.infinity,
      height: h,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, child) => Transform.scale(
                scale: 1.08 + 0.06 * Curves.easeInOut.transform(_c.value),
                child: child,
              ),
              child: Image.asset(
                'assets/images/kedi.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.25),
                filterQuality: FilterQuality.high,
              ),
            ),
            // altta uygulama rengine yumuşak geçiş
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [Colors.black.withAlpha(60), Colors.transparent, bg],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
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
