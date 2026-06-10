import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../library/library_screen.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// First-launch walk-through of the library. Re-openable from a book's index
/// drawer ("كيفية الاستخدام").
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onComplete, this.asGuide = false});

  /// Side-effect on finish (persist the "seen" flag on first run). Navigation
  /// is handled here using this screen's own context.
  final VoidCallback? onComplete;
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
      title: 'مكتبة الطريقة البرهانية',
      body: 'كتب الطريقة البرهانية الدسوقية الشاذلية، '
          'مجموعةً في تطبيق واحد، مُيسَّرةً للقراءة والبحث.',
    ),
    _OnboardPage(
      icon: Icons.library_books_rounded,
      title: 'كتابان بين يديك',
      body: 'كتاب الأوراد البرهانية — الأوراد والأحزاب اليومية.\n'
          'وديوان شراب الوصل — ٩٥ قصيدة في خمسة أجزاء.\n'
          'اختر من المكتبة ما تريد قراءته.',
    ),
    _OnboardPage(
      icon: Icons.menu_book_rounded,
      title: 'تصفّح كالكتاب',
      body: 'اسحب يمينًا ويسارًا لتقليب الصفحات، وباعِد بإصبعيك أو اضغط '
          'ضغطتين للتكبير، وضغطة واحدة لملء الشاشة.',
    ),
    _OnboardPage(
      icon: Icons.my_location_rounded,
      title: 'ابحث… وحدّد البيت',
      body: 'ابحث داخل كل كتاب. وفي الديوان تُبيّن لك النتيجة رقم البيت، '
          'وتظهر «بطاقة تحديد البيت» بنصّه أسفل الصفحة لتجده في لمحة.',
      highlightVerse: true,
    ),
    _OnboardPage(
      icon: Icons.bookmark_added_rounded,
      title: 'احفظ مكانك',
      body: 'لكل كتاب إشاراته وملاحظاته الخاصة، '
          'ويفتح كل كتاب من حيث توقّفت فيه.',
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

  void _finish() {
    widget.onComplete?.call();
    final navigator = Navigator.of(context);
    if (widget.asGuide) {
      navigator.pop();
    } else {
      navigator.pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const LibraryScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                        child: TextButton(
                          onPressed: _finish,
                          child: Text(widget.asGuide ? 'إغلاق' : 'تخطٍّ'),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          child: Text(
                            _isLast
                                ? (widget.asGuide ? 'تمّ' : 'ابدأ')
                                : 'التالي',
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
              fontSize: 26,
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

class _VersePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location_rounded,
                  color: AppColors.goldBright, size: 16),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
