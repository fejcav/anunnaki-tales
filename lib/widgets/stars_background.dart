import 'dart:math';

import 'package:flutter/material.dart';

import '../app_theme.dart';

// Fondo con estrellas sutiles y fijas (sin animación) detrás de [child].
class StarsBackground extends StatelessWidget {
  const StarsBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _StarsPainter(context.palette.stars))),
        ),
        child,
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter(this.color);

  final Color color; // el de la paleta; cada estrella le aplica su brillo

  // Posiciones relativas (0–1), tamaño y brillo de cada estrella. La semilla
  // fija hace que siempre queden en el mismo lugar.
  static final List<(double, double, double, double)> _stars = () {
    final random = Random(7);
    return List.generate(
      90,
      (_) => (
        random.nextDouble(),
        random.nextDouble(),
        0.4 + random.nextDouble() * 1.1,
        0.15 + random.nextDouble() * 0.45,
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final (x, y, radius, opacity) in _stars) {
      paint.color = color.withValues(alpha: color.a * opacity);
      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => oldDelegate.color != color;
}
