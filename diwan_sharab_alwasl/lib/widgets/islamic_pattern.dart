import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A subtle tiling Islamic geometric pattern used as a background texture.
/// Draws an interlaced grid of 8-pointed stars (two overlapping squares)
/// connected by small diamonds — the classic *khatam* motif.
class IslamicPatternBackground extends StatelessWidget {
  const IslamicPatternBackground({
    super.key,
    this.color = AppColors.gold,
    this.opacity = 0.05,
    this.tile = 64,
    this.child,
  });

  final Color color;
  final double opacity;
  final double tile;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _KhatamPainter(color: color, opacity: opacity, tile: tile),
      child: child,
    );
  }
}

class _KhatamPainter extends CustomPainter {
  _KhatamPainter({
    required this.color,
    required this.opacity,
    required this.tile,
  });

  final Color color;
  final double opacity;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color.withValues(alpha: opacity);

    final cols = (size.width / tile).ceil() + 1;
    final rows = (size.height / tile).ceil() + 1;
    final r = tile * 0.42;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cx = col * tile;
        final cy = row * tile;
        _drawStar(canvas, paint, Offset(cx, cy), r);
        // Offset stars on alternating lattice points for an interlaced feel.
        _drawStar(
          canvas,
          paint..color = color.withValues(alpha: opacity * 0.6),
          Offset(cx + tile / 2, cy + tile / 2),
          r * 0.5,
        );
        paint.color = color.withValues(alpha: opacity);
      }
    }
  }

  /// 8-pointed star = a square plus the same square rotated 45°.
  void _drawStar(Canvas canvas, Paint paint, Offset c, double r) {
    final p1 = _square(c, r, 0);
    final p2 = _square(c, r, math.pi / 4);
    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
  }

  Path _square(Offset c, double r, double rot) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = rot + i * math.pi / 2 + math.pi / 4;
      final x = c.dx + r * math.cos(a);
      final y = c.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _KhatamPainter old) =>
      old.color != color || old.opacity != opacity || old.tile != tile;
}
