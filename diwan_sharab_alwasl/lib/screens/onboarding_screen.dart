import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'reader_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// A short, branded walk-through of the diwan's features. Shown once on first
/// launch, and re-openable any time from the index drawer ("كيفية الاستخدام").
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onComplete, this.asGuide = false});

  /// Side-effect run when the user finishes/skips (e.g. persist the "seen"
  /// flag on first run). Navigation itself is handled inside this screen using
  /// its own context, so it works no matter who pushed it.
  final VoidCallback? onComplete;

  /// True when opened from the drawer (so it pops back instead of opening the
  /// reader, and the last button reads «تمّ»).
  final bool asGuide;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      logo: true,
      title: 'ديوان شَراب الوصل',
      body:
          'مجموعة قصائد الإمام فخر الدين الشيخ محمد عثمان عبده البرهاني — '
          'بين يديك كاملةً، مُيسَّرةً للقراءة والبحث.',
    ),
    _OnboardPage(
      icon: Icons.menu_book_rounded,
      title: 'تصفّح كالكتاب',
      body:
          '٢٦٨ صفحة، ٩٥ قصيدة في خمسة أجزاء.\n'
          'اسحب يمينًا ويسارًا لتقليب الصفحات، وباعِد بإصبعيك أو اضغط ضغطتين '
          'للتكبير، وضغطة واحدة لملء الشاشة.',
    ),
    _OnboardPage(
      icon: Icons.format_list_bulleted_rounded,
      title: 'فهرس القصائد',
      body:
          'افتح الفهرس من الأعلى لتجد القصائد مرتّبةً بأجزائها، '
          'كلّ قصيدة بمطلعها ونوعها (التّائِيّة، النّونِيّة…) ورقم صفحتها.',
    ),
    _OnboardPage(
      icon: Icons.my_location_rounded,
      title: 'ابحث… وحدّد البيت',
      body:
          'ابحث في ٢٬٦٨٢ بيتًا، وكلّ نتيجة تُبيّن لك رقم البيت داخل القصيدة.\n'
          'ولأنّ الصفحة قد تضمّ أكثر من بيت، فعند فتح أي نتيجة تظهر لك '
          '«بطاقة تحديد البيت» بنصّه ورقمه أسفل الصفحة — لتجده في لمحة.',
      highlightVerse: true,
    ),
    _OnboardPage(
      icon: Icons.bookmark_added_rounded,
      title: 'احفظ مكانك',
      body:
          'ضع إشارات مرجعية، واكتب ملاحظاتك على الصفحات، '
          'ويفتح التطبيق من حيث توقّفت في كلّ مرة.',
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Runs the side-effect then navigates — using this screen's own (live)
  /// context, so it works whether we were pushed by the splash or the drawer.
  void _finish() {
    widget.onComplete?.call();
    final navigator = Navigator.of(context);
    if (widget.asGuide) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const ReaderScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: IslamicPatternBackground(
          opacity: 0.05,
          tile: 72,
          child: Stack(
            children: [
              const Positioned.fill(
                child: Center(child: LogoWatermark(size: 340, opacity: 0.04)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Skip
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                        child: TextButton(
                          onPressed: _finish,
                          child: Text(
                            widget.asGuide ? 'إغلاق' : 'تخطٍّ',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontUi,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemCount: _pages.length,
                        itemBuilder: (_, i) => _OnboardView(page: _pages[i]),
                      ),
                    ),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pages.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _index ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _index
                                  ? AppColors.gold
                                  : AppColors.textMuted.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Action button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _isLast
                                ? (widget.asGuide ? 'تمّ' : 'ابدأ القراءة')
                                : 'التالي',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontUi,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData? icon;
  final bool logo;
  final String title;
  final String body;
  final bool highlightVerse;

  const _OnboardPage({
    this.icon,
    this.logo = false,
    required this.title,
    required this.body,
    this.highlightVerse = false,
  });
}

class _OnboardView extends StatelessWidget {
  const _OnboardView({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.logo)
            const SufiLogo(size: 150)
          else
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emerald.withValues(alpha: 0.22),
                    AppColors.surface.withValues(alpha: 0.0),
                  ],
                ),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(page.icon, size: 60, color: AppColors.gold),
            ),
          const SizedBox(height: 30),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontScripture,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(width: 200, child: OrnamentalDivider()),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontSize: 15.5,
              height: 1.95,
              color: AppColors.textSecondary,
            ),
          ),
          if (page.highlightVerse) ...[
            const SizedBox(height: 22),
            _VersePreview(),
          ],
        ],
      ),
    );
  }
}

/// A miniature of the real "locate verse" card, so the idea is obvious before
/// the user ever runs a search.
class _VersePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: AppColors.goldBright,
                size: 16,
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'البيت ٤٧',
                  style: TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'وَمَنَازِلُ التَّكْوِيرِ مِنْ عُرْجُونِهَا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontScripture,
              fontSize: 17,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
