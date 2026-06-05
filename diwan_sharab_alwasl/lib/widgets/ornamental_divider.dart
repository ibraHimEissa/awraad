import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A horizontal gold rule that fades out toward a central rosette glyph (۞).
/// The signature separator of the app's ornamental style.
class OrnamentalDivider extends StatelessWidget {
  const OrnamentalDivider({
    super.key,
    this.color = AppColors.gold,
    this.glyph = '۞',
    this.width,
  });

  final Color color;
  final String glyph;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.0),
              color.withValues(alpha: 0.6),
            ],
          ),
        ),
      ),
    );
    final lineRev = Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              glyph,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ),
          lineRev,
        ],
      ),
    );
  }
}

/// A small gold-bordered "pill" used for page numbers and badges.
class GoldPill extends StatelessWidget {
  const GoldPill({
    super.key,
    required this.child,
    this.onTap,
    this.filled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool filled;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? AppColors.gold.withValues(alpha: 0.14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
