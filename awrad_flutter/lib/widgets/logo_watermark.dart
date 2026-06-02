import 'package:flutter/material.dart';

/// A faint, decorative logo watermark used to give screens a subtle branded
/// texture without distracting from the text.
class LogoWatermark extends StatelessWidget {
  const LogoWatermark({
    super.key,
    this.size = 280,
    this.opacity = 0.05,
    this.alignment = Alignment.center,
  });

  final double size;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
