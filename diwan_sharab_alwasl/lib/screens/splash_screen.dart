import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/book_data.dart';
import '../state/book_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';
import 'onboarding_screen.dart';
import 'reader_screen.dart';

/// Opening screen: logo + title over a patterned emerald field, then fades
/// into the reader.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _rise = Tween(
      begin: 18.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 2100), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final controller = context.read<BookController>();
    final Widget next = controller.seenOnboarding
        ? const ReaderScreen()
        : OnboardingScreen(onComplete: controller.markOnboardingSeen);
    Navigator.of(context).pushReplacement(_fadeRoute(next));
  }

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: IslamicPatternBackground(
          opacity: 0.06,
          tile: 72,
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: AnimatedBuilder(
                animation: _rise,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _rise.value),
                  child: child,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SufiLogo(size: 168),
                    const SizedBox(height: 26),
                    const Text(
                      BookData.bookTitle,
                      style: TextStyle(
                        fontFamily: AppTheme.fontScripture,
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        color: AppColors.gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(width: 240, child: OrnamentalDivider()),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        BookData.orderName,
                        style: TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
