import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The order's logo with an optional soft, breathing gold halo behind it.
class SufiLogo extends StatefulWidget {
  const SufiLogo({super.key, this.size = 64, this.showGlow = true});

  final double size;
  final bool showGlow;

  @override
  State<SufiLogo> createState() => _SufiLogoState();
}

class _SufiLogoState extends State<SufiLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.showGlow) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/logo.png',
      width: widget.size,
      height: widget.size,
      filterQuality: FilterQuality.high,
    );

    if (!widget.showGlow) {
      return SizedBox(width: widget.size, height: widget.size, child: logo);
    }

    return SizedBox(
      width: widget.size * 1.6,
      height: widget.size * 1.6,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          final glow = 0.18 + t * 0.18;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * (1.25 + t * 0.2),
                height: widget.size * (1.25 + t * 0.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldBright.withValues(alpha: glow),
                      AppColors.emerald.withValues(alpha: glow * 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: logo,
      ),
    );
  }
}
